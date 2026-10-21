# Hook SessionStart (matcher compact): reinyecta el estado del repo despues de compactar el contexto.
# Imprime la rama, ESTADO.md completo, la lista de planes/activos/ y las primeras 25 lineas de git status --short; lo que
# sale por stdout entra al contexto. En ese orden: si la salida es larga solo entra el principio, y git status es lo que
# mas crece.
# ESTADO.md tiene acentos: se lee como UTF-8 y se escribe en UTF-8 sin BOM, igual en 5.1 y en 7.
# Solo ASCII: lo ejecuta powershell.exe 5.1. Siempre sale con 0 para no frenar la sesion.
$raiz = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
$salida = [Console]::Out

$rama = (& git -C $raiz branch --show-current 2>$null) -join ''
if ([string]::IsNullOrWhiteSpace($rama)) { $rama = '(sin rama: HEAD separado o git no disponible)' }
$salida.WriteLine("Rama actual: $rama")
$salida.WriteLine('')

$estado = Join-Path $raiz 'ESTADO.md'
if (Test-Path -LiteralPath $estado) {
    $salida.WriteLine('--- ESTADO.md ---')
    foreach ($linea in (Get-Content -LiteralPath $estado -Encoding UTF8)) { $salida.WriteLine($linea) }
    $salida.WriteLine('--- fin de ESTADO.md ---')
}
else { $salida.WriteLine('ESTADO.md no existe en la raiz del repo.') }
$salida.WriteLine('')

$activos = Join-Path $raiz 'planes/activos'
$planes = @(Get-ChildItem -LiteralPath $activos -Filter '*.md' -File -ErrorAction SilentlyContinue | Sort-Object Name)
$salida.WriteLine('Planes activos:')
if ($planes.Count -eq 0) { $salida.WriteLine('  (ninguno)') }
foreach ($plan in $planes) { $salida.WriteLine("  planes/activos/$($plan.Name)") }
$salida.WriteLine('')

$cambios = @(& git -C $raiz status --short 2>$null)
$salida.WriteLine('git status --short:')
if ($cambios.Count -eq 0) { $salida.WriteLine('  (sin cambios)') }
foreach ($cambio in ($cambios | Select-Object -First 25)) { $salida.WriteLine("  $cambio") }
if ($cambios.Count -gt 25) { $salida.WriteLine("  ($($cambios.Count - 25) mas: git status --short)") }
$salida.WriteLine('')

$salida.WriteLine('Vuelve a leer el CLAUDE.md y el funciones.json del bloque en curso.')
exit 0
