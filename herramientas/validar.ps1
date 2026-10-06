# Valida el proyecto: importa, corre la escena validadora y revisa su salida.
# Sale con 0 solo si la escena imprime "VALIDACION ... fallos=0" y no hay lineas de error.
# Solo ASCII: powershell.exe 5.1 lee los .ps1 sin BOM como ANSI.
param([switch]$SinImportar)

$godot = $env:GODOT_PATH
if (-not $godot -or -not (Test-Path -LiteralPath $godot)) {
    Write-Output 'validar: define GODOT_PATH con la ruta del ejecutable de consola de Godot 4.7.2'
    exit 2
}
$raiz = Split-Path -Parent $PSScriptRoot
$log = Join-Path $raiz '.godot\validar.log'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $log) | Out-Null

# cmd /c une stdout y stderr sin que PowerShell 5.1 convierta stderr en errores.
Set-Content -LiteralPath $log -Value '' -NoNewline
if (-not $SinImportar) {
    cmd /c "`"$godot`" --headless --path `"$raiz`" --import >> `"$log`" 2>&1"
}
cmd /c "`"$godot`" --headless --path `"$raiz`" res://herramientas/validar.tscn --quit-after 600 >> `"$log`" 2>&1"
$codigo = $LASTEXITCODE

$lineas = @(Get-Content -LiteralPath $log)
$errores = @($lineas | Where-Object { $_ -match 'SCRIPT ERROR|^\s*ERROR:|^FALLO ' })
$resumen = @($lineas | Where-Object { $_ -match '^VALIDACION archivos=\d+ fallos=\d+$' })

if ($errores.Count -eq 0 -and $codigo -eq 0 -and $resumen.Count -eq 1 -and $resumen[0] -match 'fallos=0$') {
    Write-Output ("OK  " + $resumen[0])
    exit 0
}
$errores | Select-Object -First 20 | ForEach-Object { Write-Output $_ }
if ($resumen.Count -eq 0) { Write-Output 'validar: la escena validadora no imprimio su resumen (no corrio completa)' }
else { Write-Output $resumen[0] }
Write-Output ("FALLA  detalle en " + $log)
exit 1
