# Consulta todos los PR cerrados con gh api (GET) y conserva solo los fusionados.
# Repo explicito para no invocar git. Solo publica localmente numero, titulo y fecha UTC.
param([string]$Repositorio = 'TheMike54/el-paso-final')

$raiz = Split-Path -Parent $PSScriptRoot
$salida = Join-Path $raiz 'docs/entrega-2.md'
if ($Repositorio -notmatch '^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$') {
    Write-Output 'ENTREGA FALLA: repositorio invalido (owner/repo)'
    exit 1
}
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Output 'ENTREGA FALLA: falta gh'
    exit 1
}
# No ErrorActionPreference=Stop: PS 5.1 trata stderr nativo como ErrorRecord.
$encodingAnterior = [Console]::OutputEncoding
try {
    [Console]::OutputEncoding = New-Object Text.UTF8Encoding($false)
    $respuesta = @(& gh api --method GET --paginate "repos/$Repositorio/pulls?state=closed&per_page=100" --jq '.[] | select(.merged_at != null) | [.number, .title, .merged_at] | @json' 2>&1)
    $codigoGh = $LASTEXITCODE
} finally { [Console]::OutputEncoding = $encodingAnterior }
if ($codigoGh -ne 0) {
    Write-Output 'ENTREGA FALLA: gh no pudo consultar los PR fusionados; no se escribio docs/entrega-2.md'
    exit 1
}

function ConvertTo-Celda([string]$valor) {
    # Evita que un titulo rompa la tabla o inserte HTML.
    return $valor.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('|', '&#124;').Replace('`', '&#96;').Replace('[', '&#91;').Replace(']', '&#93;').Replace("`r", ' ').Replace("`n", ' ')
}

try {
    $prs = @(foreach ($linea in $respuesta) {
        if ([string]::IsNullOrWhiteSpace([string]$linea)) { continue }
        $dato = ConvertFrom-Json -InputObject ([string]$linea) -ErrorAction Stop
        if ($dato -isnot [Array] -or $dato.Count -ne 3 -or $dato[0] -notmatch '^\d+$') {
            throw 'Respuesta inesperada de gh'
        }
        # PS 7 convierte fechas JSON a DateTime; PS 5.1 conserva el texto.
        $fecha = if ($dato[2] -is [DateTime]) { $dato[2].ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss'Z'") } else { [string]$dato[2] }
        if ($fecha -notmatch '^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ$') { throw 'Fecha inesperada de gh' }
        [pscustomobject]@{ Numero = [int]$dato[0]; Titulo = [string]$dato[1]; Fecha = $fecha }
    })
    $lineas = @('# Entrega 2', '', ('PR fusionados de ' + $Repositorio + '. Fechas de fusion en UTC.'), '', '| Numero | Titulo | Fecha |', '|---|---|---|')
    foreach ($pr in @($prs | Sort-Object Numero)) {
        $lineas += ('| {0} | {1} | {2} |' -f $pr.Numero, (ConvertTo-Celda $pr.Titulo), $pr.Fecha)
    }
    [IO.File]::WriteAllText($salida, (($lineas -join "`n") + "`n"), (New-Object Text.UTF8Encoding($false)))
    Write-Output ('ENTREGA prs={0} archivo=docs/entrega-2.md' -f $prs.Count)
    exit 0
} catch {
    Write-Output ('ENTREGA FALLA: ' + $_.Exception.Message)
    exit 1
}
