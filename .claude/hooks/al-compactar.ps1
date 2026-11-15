# Hook SessionStart (matcher compact): reinyecta el estado del repo despues de compactar el contexto.
# Imprime la rama, ESTADO.md completo (con su "## Decidido"), la lista de planes/activos/, la seccion de decisiones de
# cada plan activo ("## Decidido..." o "## Decisiones cerradas...", hasta el siguiente "## ") y las primeras lineas de
# git status --short; lo que sale por stdout entra al contexto. Claude Code corta la salida de un hook en 10000
# caracteres y, si se pasa, Claude solo ve una vista previa de 2000: git status va al final y se recorta para que el
# total quede debajo de $tope; si aun asi se pasa, la primera linea lo avisa.
# ESTADO.md y los planes tienen acentos: se leen como UTF-8 y se escriben en UTF-8 sin BOM, igual en 5.1 y en 7.
# Solo ASCII: lo ejecuta powershell.exe 5.1. Siempre sale con 0 para no frenar la sesion.
$raiz = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
$texto = New-Object System.Text.StringBuilder
$tope = 9000
function Linea([string]$s) { [void]$texto.AppendLine($s) }

$rama = (& git -C $raiz branch --show-current 2>$null) -join ''
if ([string]::IsNullOrWhiteSpace($rama)) { $rama = '(sin rama: HEAD separado o git no disponible)' }
Linea "Rama actual: $rama"
Linea ''

$estado = Join-Path $raiz 'ESTADO.md'
if (Test-Path -LiteralPath $estado) {
    Linea '--- ESTADO.md ---'
    foreach ($l in (Get-Content -LiteralPath $estado -Encoding UTF8)) { Linea $l }
    Linea '--- fin de ESTADO.md ---'
}
else { Linea 'ESTADO.md no existe en la raiz del repo.' }
Linea ''

$activos = Join-Path $raiz 'planes/activos'
$planes = @(Get-ChildItem -LiteralPath $activos -Filter '*.md' -File -ErrorAction SilentlyContinue | Sort-Object Name)
Linea 'Planes activos:'
if ($planes.Count -eq 0) { Linea '  (ninguno)' }
foreach ($plan in $planes) { Linea "  planes/activos/$($plan.Name)" }
Linea ''

foreach ($plan in $planes) {
    $dentro = $false
    foreach ($l in (Get-Content -LiteralPath $plan.FullName -Encoding UTF8)) {
        if ($l.StartsWith('## ')) {
            $dentro = $l -match '^## (Decidido|Decisiones cerradas)'
            if ($dentro) { Linea "--- planes/activos/$($plan.Name): $($l.Substring(3)) ---" }
            continue
        }
        if ($dentro -and $l.Trim().Length -gt 0) { Linea $l }
    }
}
Linea ''

$cierre = 'Vuelve a leer el CLAUDE.md y el funciones.json del bloque en curso.'
$cambios = @(& git -C $raiz status --short 2>$null)
Linea 'git status --short:'
if ($cambios.Count -eq 0) { Linea '  (sin cambios)' }
$puestos = 0
foreach ($c in $cambios) {
    if ($puestos -ge 25 -or ($texto.Length + $c.Length + $cierre.Length + 80) -gt $tope) { break }
    Linea "  $c"
    $puestos++
}
if ($cambios.Count -gt $puestos) { Linea "  ($($cambios.Count - $puestos) mas: git status --short)" }
Linea ''
Linea $cierre

if ($texto.Length -gt 9800) {
    [void]$texto.Insert(0, "AVISO: esta salida pasa de 10000 caracteres y no entra completa. Lee ESTADO.md y la seccion de decisiones de cada plan activo.`r`n")
}
[Console]::Out.Write($texto.ToString())
exit 0
