# Revisa destinos locales Markdown y rutas completas entre comillas invertidas.
# Las rutas en prosa pueden ser relativas al documento o a la raiz del repo.
# Omite plantillas, globos, URLs externas, bloques de codigo y el historial (docs/errores, planes/cerrados); nunca sale del repo.
param()

$raiz = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$revisados = 0
$rotos = 0

function Get-Markdown($carpeta) {
    foreach ($item in Get-ChildItem -LiteralPath $carpeta -Force -ErrorAction Stop) {
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
        if ($item.PSIsContainer) {
            if ($item.Name -notin @('.godot', 'build', '.git', 'errores', 'cerrados')) { Get-Markdown $item.FullName }
        } elseif ($item.Extension -ieq '.md' -and $item.Name -ne 'CLAUDE.local.md') { $item.FullName }
    }
}

function Test-Destino($texto, $documento, $esEnlace) {
    $ruta = $texto.Trim()
    if ($ruta -match '^<([^<>]+)>$') { $ruta = $Matches[1] }
    if ($ruta -match '^(#|//)' -or $ruta -match '^(?!res:)[a-zA-Z][a-zA-Z0-9+.-]*:') { return }
    if ($esEnlace) { $ruta = ($ruta -split '[#?]', 2)[0] }
    $ruta = [Uri]::UnescapeDataString($ruta)
    # Los ejemplos con huecos, variables o comodines no prometen un archivo existente.
    if ($ruta -match '[<>*?{}$]' -or $ruta.Contains('...') -or $ruta.Contains('AAAA-MM-DD')) { return }
    # La cache local no existe en un clon limpio.
    if ($ruta -match '^\.godot[/\\]') { return }
    # Rutas que los documentos describen como opcionales o que viven en el telefono.
    if ($ruta -in @('contenido/preguntas_mochila.tres', 'contenido/estaciones.tres', 'files/prueba_partida.json')) { return }
    if (-not $esEnlace -and $ruta -notmatch '^(?:res://|\.?\.?[/\\])?[^\s`"|=]+(?:[/\\][^\s`"|=]+)*\.[a-zA-Z0-9_-]+(?::\d+(?:-\d+)?)?(?:#[^\s]*)?$') { return }
    # Las citas de la documentacion de Godot son relativas a GODOT_DOCS, fuera del repo.
    if ($ruta -match '^(tutorials|classes|getting_started|contributing|engine_details)/') { return }
    # Un nombre suelto como jugador.gd no dice carpeta: solo se revisan rutas con carpeta.
    if (-not $esEnlace -and $ruta -notmatch '[/\\]') { return }
    # Un miembro como Partida.equipar o un decimal no es una ruta de archivo.
    if (-not $esEnlace -and $ruta -notmatch '(?i)\.(?:md|txt|json|gd|gd\.uid|tscn|tres|ps1|sh|rst|png|jpg|jpeg|webp|svg|ogg|wav|mp3|mp4|ogv|ttf|otf|godot|cfg|yml|yaml|toml|xml|csv|tsv|zip|apk|aab|py|cs|import|guion|esperado|gdshader|gdignore|gitattributes|gitignore|pdf|docx|xlsx|pptx|html|css|js|ts|exe|bat|cmd|log|ini)(?::\d+(?:-\d+)?)?(?:#[^\s]*)?$') { return }
    $ruta = [Uri]::UnescapeDataString(($ruta -split '[#?]', 2)[0])
    $ruta = $ruta -replace ':\d+(?:-\d+)?$', ''
    if ($ruta -eq '') { return }
    $bases = @((Split-Path -Parent $documento))
    if ($ruta.StartsWith('res://')) {
        $ruta = $ruta.Substring(6)
        $bases = @($raiz)
    } elseif ($ruta.StartsWith('/')) {
        $ruta = $ruta.TrimStart('/')
        $bases = @($raiz)
    } elseif (-not $esEnlace) { $bases += $raiz }
    $script:revisados++
    foreach ($base in $bases) {
        try {
            # Los documentos citan rutas con \ (PowerShell) o /; en Linux la \ no separa carpetas.
            $destino = [IO.Path]::GetFullPath((Join-Path $base $ruta.Replace('\', '/').Replace('/', [IO.Path]::DirectorySeparatorChar)))
            if (-not $destino.StartsWith($raiz + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -and $destino -ne $raiz) { continue }
            if (Test-Path -LiteralPath $destino) { return }
        } catch { continue }
    }
    $script:rotos++
    $rel = $documento.Substring($raiz.Length + 1).Replace('\', '/')
    Write-Output ('ROTO {0}:{1} {2}' -f $rel, $script:numeroLinea, $texto)
}

try {
    $documentos = @(Get-Markdown $raiz | Sort-Object)
    foreach ($documento in $documentos) {
        $numeroLinea = 0
        $cerca = ''
        foreach ($linea in [IO.File]::ReadAllLines($documento)) {
            $numeroLinea++
            if ($linea -match '^\s{0,3}(`{3,}|~{3,})') {
                $marca = $Matches[1]
                if ($cerca -eq '') { $cerca = $marca }
                elseif ($marca[0] -eq $cerca[0] -and $marca.Length -ge $cerca.Length) { $cerca = '' }
                continue
            }
            if ($cerca -ne '') { continue }
            # Primero el codigo en linea; se quita antes de buscar enlaces de Markdown.
            foreach ($m in [regex]::Matches($linea, '(?<!`)`([^`\r\n]+)`(?!`)')) {
                Test-Destino $m.Groups[1].Value $documento $false
            }
            $prosa = [regex]::Replace($linea, '(?<!`)`([^`\r\n]+)`(?!`)', '')
            foreach ($m in [regex]::Matches($prosa, '\[[^\]]*\]\(\s*(<[^>]+>|[^\s()]*(?:\([^()]*\)[^\s()]*)*)(?:\s+"[^"]*")?\s*\)')) {
                Test-Destino $m.Groups[1].Value $documento $true
            }
            if ($prosa -match '^\s{0,3}\[[^\]]+\]:\s*(<[^>]+>|\S+)') {
                Test-Destino $Matches[1] $documento $true
            }
        }
    }
} catch {
    Write-Output ('ROTO lectura: ' + $_.Exception.Message)
    $rotos++
}
Write-Output ('ENLACES revisados={0} rotos={1}' -f $revisados, $rotos)
if ($rotos -gt 0) { exit 1 }
exit 0
