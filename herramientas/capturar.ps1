# Saca las capturas de una sala del juego en varias resoluciones (por omision 3), en la PC y con ventana.
# Uso: .\herramientas\capturar.ps1 -Sala celda_1 [-Resoluciones 1280x720,1920x1080,2560x1440] [-Salida <carpeta>]
#                                  [-Recursos bajo|alto] [-Puntos "640:360;1700:360"]
# Las resoluciones por omision son las de los monitores de 10" a 27": 1280x720, 1920x1080 y 2560x1440. La de
# 2560x1440 solo cabe con ventana en un monitor mayor que ella; en uno de 2560x1440 puede fallar por tamano.
# Por omision las posiciones son la rejilla de herramientas/pruebas/medicion.gd (llega a los extremos de la camara de
# la sala) y la carpeta es build\capturas\<sala>-<fecha>. Cada resolucion es una corrida de Godot con su propio tiempo
# limite; si se pasa, se mata solo ese proceso. Falla si el tamano de una imagen no es el pedido (la ventana no cupo).
# Termina con "CAPTURAR OK ..." (salida 0) o "CAPTURAR FALLA ..." (salida 1). Solo ASCII; powershell.exe 5.1 y pwsh 7.
param(
    [Parameter(Mandatory = $true)][string]$Sala,
    [string[]]$Resoluciones = @('1280x720', '1920x1080', '2560x1440'),
    [string]$Salida = '',
    [ValidateSet('bajo', 'alto')][string]$Recursos = 'bajo',
    [string]$Puntos = '',
    [int]$SegundosMax = 180
)

$raiz = Split-Path -Parent $PSScriptRoot
function Fallar([string]$motivo) { Write-Output ('CAPTURAR FALLA ' + $motivo); exit 1 }

if ($Sala -notmatch '^[A-Za-z0-9_]+$') { Fallar ("sala '" + $Sala + "' no es un id (letras, numeros y _)") }
if ($Puntos -and $Puntos -notmatch '^[0-9.:;-]+$') { Fallar ("-Puntos solo admite numeros, ':' y ';'") }
$godot = $env:GODOT_PATH
if (-not $godot -or -not (Test-Path -LiteralPath $godot)) { Fallar 'GODOT_PATH no apunta al ejecutable de consola de Godot 4.7.2' }
if (-not (Test-Path -LiteralPath (Join-Path $raiz 'herramientas\pruebas\capturar_sala.tscn'))) { Fallar 'falta herramientas\pruebas\capturar_sala.tscn' }
foreach ($r in $Resoluciones) { if ($r -notmatch '^\d+x\d+$') { Fallar ("resolucion '" + $r + "' no es AnchoxAlto") } }

$vivos = @(Get-Process -Name 'Godot*' -ErrorAction SilentlyContinue)
if ($vivos.Count -gt 0) {
    Write-Output ('aviso  hay ' + $vivos.Count + ' proceso(s) de Godot vivos (' + (($vivos | ForEach-Object { $_.Id }) -join ', ') + '): si uno corre guiones, espera a que acabe')
}

if (-not $Salida) { $Salida = Join-Path $raiz ('build\capturas\' + $Sala + '-' + (Get-Date).ToString('yyyyMMdd-HHmmss')) }
elseif (-not [System.IO.Path]::IsPathRooted($Salida)) { $Salida = Join-Path $raiz $Salida }
New-Item -ItemType Directory -Force -Path $Salida | Out-Null
$salidaGodot = $Salida -replace '\\', '/'

$archivos = 0
foreach ($resolucion in $Resoluciones) {
    $registro = Join-Path $Salida ('godot-' + $resolucion + '.log')
    $argumentos = @('--path', ('"' + $raiz + '"'), '--windowed', '--resolution', $resolucion, 'res://herramientas/pruebas/capturar_sala.tscn',
        '--', ('--sala=' + $Sala), ('--salida="' + $salidaGodot + '"'), ('--etiqueta=' + $resolucion), ('--recursos=' + $Recursos))
    if ($Puntos) { $argumentos += ('--puntos=' + $Puntos) }
    $p = Start-Process -FilePath $godot -ArgumentList $argumentos -PassThru -NoNewWindow `
        -RedirectStandardOutput $registro -RedirectStandardError ($registro + '.err')
    if (-not $p.WaitForExit($SegundosMax * 1000)) {
        Stop-Process -Id $p.Id -Force
        Fallar ($resolucion + ': Godot paso de ' + $SegundosMax + ' s y se detuvo; detalle en ' + $registro)
    }
    $lineas = @(Get-Content -LiteralPath $registro -ErrorAction SilentlyContinue)
    $errores = @($lineas | Where-Object { $_ -match 'SCRIPT ERROR|^ERROR:|Parse Error' })
    if ($errores.Count -gt 0) { Fallar ($resolucion + ': ' + $errores[0] + ' (detalle en ' + $registro + ')') }
    $resumen = @($lineas | Where-Object { $_ -match '^CAPTURAS sala=' })
    if ($resumen.Count -ne 1) { Fallar ($resolucion + ': Godot no imprimio el resumen "CAPTURAS ..."; detalle en ' + $registro) }
    if ($resumen[0] -notmatch 'total=(\d+) fallos=0') { Fallar ($resolucion + ': ' + $resumen[0]) }
    $total = [int]$Matches[1]
    $hechas = @($lineas | Where-Object { $_ -match '^CAPTURA archivo=' })
    if ($total -lt 1 -or $hechas.Count -ne $total) { Fallar ($resolucion + ': total=' + $total + ' pero hay ' + $hechas.Count + ' lineas de captura') }
    foreach ($linea in $hechas) {
        if ($linea -notmatch '^CAPTURA archivo=(.+) tam=(\d+x\d+)$') { Fallar ($resolucion + ': linea ilegible: ' + $linea) }
        $ruta = $Matches[1]
        $tam = $Matches[2]
        if (-not (Test-Path -LiteralPath $ruta) -or (Get-Item -LiteralPath $ruta).Length -le 0) { Fallar ($resolucion + ': no existe o esta vacia ' + $ruta) }
        if ($tam -ne $resolucion) { Fallar ($resolucion + ': la imagen midio ' + $tam + ' (la ventana no cupo en la pantalla): ' + $ruta) }
        $archivos++
    }
    Write-Output ('ok     ' + $resolucion + ': ' + $total + ' capturas')
}
Write-Output ('CAPTURAR OK sala=' + $Sala + ' resoluciones=' + $Resoluciones.Count + ' archivos=' + $archivos + ' carpeta=' + $Salida)
exit 0
