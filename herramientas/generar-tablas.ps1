# Lee escenas, autoloads y el script del bus real, sin ejecutar Godot.
# Salida UTF-8 sin BOM y LF, orden ordinal y sin fechas para poder regenerarla.
param()

$raiz = Split-Path -Parent $PSScriptRoot
$salida = Join-Path $raiz 'docs/manual/tablas-generadas.md'
$lineas = New-Object 'System.Collections.Generic.List[string]'
try {
    $lineas.Add('# Tablas generadas del proyecto')
    $lineas.Add('')
    $lineas.Add('Generadas por `herramientas/generar-tablas.ps1` desde los archivos del proyecto.')
    $lineas.Add('')
    $lineas.Add('## Escenas de nucleo y contenido')
    $lineas.Add('')
    $lineas.Add('| Escena |')
    $lineas.Add('|---|')
    [string[]]$escenas = @(foreach ($bloque in @('nucleo', 'contenido')) {
        Get-ChildItem -LiteralPath (Join-Path $raiz $bloque) -Recurse -File -Filter '*.tscn' -ErrorAction Stop |
            ForEach-Object { $_.FullName.Substring($raiz.Length + 1).Replace('\', '/') }
    })
    [Array]::Sort($escenas, [StringComparer]::Ordinal)
    foreach ($escena in $escenas) { $lineas.Add('| `' + $escena + '` |') }
    $lineas.Add('')
    $lineas.Add('## Autoloads de project.godot')
    $lineas.Add('')
    $lineas.Add('| Nombre | Ruta | Singleton |')
    $lineas.Add('|---|---|---|')
    $enAutoload = $false
    $autoloads = 0
    $bus = $null
    foreach ($linea in [IO.File]::ReadAllLines((Join-Path $raiz 'project.godot'))) {
        if ($linea -match '^\s*\[([^]]+)\]') { $enAutoload = $Matches[1] -eq 'autoload'; continue }
        if ($enAutoload -and $linea -match '^\s*([^=]+)="(\*?)(res://[^"]+)"\s*$') {
            $nombre = $Matches[1].Trim()
            $singleton = if ($Matches[2] -eq '*') { 'si' } else { 'no' }
            $ruta = $Matches[3]
            $lineas.Add(('| `{0}` | `{1}` | {2} |' -f $nombre, $ruta, $singleton))
            if ($nombre -eq 'Eventos') { $bus = $ruta.Substring(6) }
            $autoloads++
        }
    }
    if (-not $bus) { throw 'No se encontro el autoload Eventos en project.godot' }
    $lineas.Add('')
    $lineas.Add('## Senales del bus de eventos')
    $lineas.Add('')
    $lineas.Add('Fuente: `' + $bus + '`. Orden de declaracion.')
    $lineas.Add('')
    $lineas.Add('| Senal | Argumentos |')
    $lineas.Add('|---|---|')
    $senales = 0
    foreach ($linea in [IO.File]::ReadAllLines((Join-Path $raiz $bus))) {
        if ($linea -match '^signal\s+(\w+)(?:\((.*)\))?\s*(?:#.*)?$') {
            $argumentos = if ($Matches[2]) { '`' + $Matches[2].Trim() + '`' } else { '-' }
            $lineas.Add(('| `{0}` | {1} |' -f $Matches[1], $argumentos))
            $senales++
        }
    }
    if ($senales -eq 0) { throw 'El bus no contiene senales reconocibles' }
    [IO.Directory]::CreateDirectory((Split-Path -Parent $salida)) | Out-Null
    [IO.File]::WriteAllText($salida, (($lineas -join "`n") + "`n"), (New-Object Text.UTF8Encoding($false)))
    Write-Output ('TABLAS escenas={0} autoloads={1} senales={2} archivo=docs/manual/tablas-generadas.md' -f $escenas.Count, $autoloads, $senales)
    exit 0
} catch {
    Write-Output ('TABLAS FALLA: ' + $_.Exception.Message)
    exit 1
}
