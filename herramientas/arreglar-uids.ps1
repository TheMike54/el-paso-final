# Pone el uid de cada ext_resource (y el de la cabecera, si falta) en las escenas y recursos escritos a mano.
# Uso: .\herramientas\arreglar-uids.ps1 -Rutas res://contenido/objetos/celda/pieza.tscn,res://contenido/salas/celda/celda_6.tscn
# Importa antes, para que los destinos nuevos ya tengan su uid. Sale con 0 solo si imprime "UIDS ... errores=0".
# Solo ASCII: powershell.exe 5.1 lee los .ps1 sin BOM como ANSI.
param([Parameter(Mandatory = $true)][string[]]$Rutas)

$godot = $env:GODOT_PATH
if (-not $godot -or -not (Test-Path -LiteralPath $godot)) {
    Write-Output 'arreglar-uids: define GODOT_PATH con la ruta del ejecutable de consola de Godot 4.7.2'
    exit 2
}
$raiz = Split-Path -Parent $PSScriptRoot
$lista = $Rutas -join ','

cmd /c "`"$godot`" --headless --path `"$raiz`" --import > nul 2>&1"
$salida = @(cmd /c "`"$godot`" --headless --path `"$raiz`" --quit-after 600 res://herramientas/arreglar_uids.tscn -- --rutas=$lista 2>&1")
$salida | Where-Object { $_ -match '^UIDS ' } | ForEach-Object { Write-Output $_ }
$resumen = @($salida | Where-Object { $_ -match '^UIDS rutas=\d+ cambiados=\d+ errores=\d+$' })
if ($resumen.Count -eq 1 -and $resumen[0] -match 'errores=0$') { exit 0 }
exit 1
