# Mide los FPS del juego en un telefono con un protocolo fijo, y deja el resultado y sus condiciones en un archivo.
# Uso: .\herramientas\medir-fps.ps1 -Telefono S503124334437 [-Etiqueta celda_2-sala] [-Segundos 30] [-Recursos bajo] [-Abrir]
# Hace falta el APK del preset Desarrollo (arranca con --print-fps) ya instalado: .\herramientas\instalar-apk.ps1.
# Protocolo (el mismo para cualquier medicion que cite este script):
#   1. El telefono esta en "device" y el paquete instalado; se anota su lastUpdateTime (que APK se midio).
#   2. Se leen los ajustes del telefono (files/ajustes.json): falla si "Ver hitbox" esta encendido (redibuja todo y la
#      medida no vale) o si el modo de Recursos no es el pedido en -Recursos; se anotan recursos, fps elegidos y mostrar_fps.
#   3. La app debe estar en primer plano (mCurrentFocus). Con -Abrir se cierra y se abre de cero; sin -Abrir se mide lo que
#      haya en pantalla (la persona o Claude ya llego a la sala). El foco se vuelve a revisar cada 5 s y al final.
#   4. Durante -Segundos se guarda "adb logcat -s godot" en un archivo mientras ocurre (no se lee despues con logcat -d:
#      el bufer es chico y pierde lineas). Se anota la temperatura de la bateria antes y despues.
#   5. Valido solo con foco todo el tiempo y al menos la mitad de los segundos con una lectura de FPS.
# Imprime una linea "FPS ..." (media, mediana, minimo, maximo, muestras; no hay "peor cuadro": --print-fps no lo da) y termina con "MEDIR-FPS OK" (salida 0) o
# "MEDIR-FPS FALLA" (salida 1). El archivo build\fps-<serie>-<fecha>.txt lleva esa linea y las lineas crudas del log.
# El formato exacto de la linea que imprime --print-fps no esta documentado: el script toma el numero que sigue a "FPS"
# (o el que lo precede) y guarda las lineas crudas para poder revisarlo. Solo ASCII; powershell.exe 5.1 y pwsh 7.
param(
    [Parameter(Mandatory = $true)][string]$Telefono,
    [string]$Preset = 'Desarrollo',
    [string]$Etiqueta = '',
    [int]$Segundos = 30,
    [ValidateSet('', 'auto', 'bajo', 'alto')][string]$Recursos = '',
    [switch]$Abrir,
    [string]$Salida = ''
)

$raiz = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'telefono-comun.ps1')
$inv = [Globalization.CultureInfo]::InvariantCulture
$fmt = 'yyyy-MM-dd HH:mm:ss'
function Fallar([string]$motivo) { Write-Output ('MEDIR-FPS FALLA ' + $motivo); exit 1 }

if ($Segundos -lt 10) { Fallar '-Segundos debe ser al menos 10' }
if ($Etiqueta -and $Etiqueta -notmatch '^[A-Za-z0-9_.-]+$') { Fallar '-Etiqueta solo admite letras, numeros, _ . -' }
$adb = Buscar-Adb
if (-not $adb) { Fallar 'no hay adb (Android SDK, platform-tools)' }
$cfg = Join-Path $raiz 'export_presets.cfg'
if (-not (Test-Path -LiteralPath $cfg)) { Fallar ('no existe ' + $cfg) }
$paquete = (Leer-Preset $cfg $Preset).Paquete
if (-not $paquete -or $paquete -notmatch '^[A-Za-z0-9_.]+$') { Fallar ("no hay preset '" + $Preset + "' con un package/unique_name valido") }

# 1. Telefono y APK instalado
if (-not (Esperar-Telefono $adb $Telefono)) { Fallar $script:Motivo }
$modelo = Modelo-Telefono $adb $Telefono
$instalados = Adb-Texto $adb $Telefono @('shell', ('pm list packages ' + $paquete))
if (@($instalados -split "`n" | ForEach-Object { $_.Trim() }) -notcontains ('package:' + $paquete)) { Fallar ($paquete + ' no esta instalado en ' + $Telefono) }
$actualizado = Ultima-Actualizacion $adb $Telefono $paquete
if (-not $actualizado) { Fallar ('no se pudo leer lastUpdateTime de ' + $paquete) }

# 2. Ajustes del telefono
$texto = Adb-Texto $adb $Telefono @('shell', ('run-as ' + $paquete + ' cat files/ajustes.json'))
$ajustes = $null
if ($script:CodigoAdb -eq 0) { try { $ajustes = ($texto | ConvertFrom-Json).ajustes } catch { $ajustes = $null } }
if ($ajustes) {
    if ($ajustes.ver_hitbox -eq $true) { Fallar 'Ver hitbox esta encendido en el telefono: apagarlo y repetir' }
    if ($Recursos -and [string]$ajustes.recursos -ne $Recursos) { Fallar ("Recursos esta en '" + $ajustes.recursos + "' y se pidio '" + $Recursos + "'") }
    $condiciones = 'recursos=' + $ajustes.recursos + ' fps_elegidos=' + $ajustes.fps + ' mostrar_fps=' + $ajustes.mostrar_fps
}
else {
    if ($Recursos) { Fallar ("no se pudo leer files/ajustes.json y se pidio Recursos '" + $Recursos + "'") }
    $condiciones = 'recursos=sin_ajustes_guardados(por_omision) fps_elegidos=? mostrar_fps=?'
    Write-Output 'aviso  sin files/ajustes.json: se miden los ajustes por omision del juego'
}

function Temperatura([string]$serie) {
    $t = Adb-Texto $adb $serie @('shell', 'dumpsys battery')
    if ($t -match 'temperature:\s*(\d+)') { return ([int]$Matches[1] / 10.0).ToString('0.0', $inv) }
    return '?'
}
function En-Primer-Plano([string]$serie) { return ((Foco-Actual $adb $serie) -match ([regex]::Escape($paquete) + '/')) }

# 3. Primer plano
if ($Abrir) {
    $null = Adb-Texto $adb $Telefono @('shell', ('am force-stop ' + $paquete))
    $null = Adb-Texto $adb $Telefono @('shell', ('monkey -p ' + $paquete + ' -c android.intent.category.LAUNCHER 1'))
    $limite = (Get-Date).AddSeconds(40)
    while (-not (En-Primer-Plano $Telefono) -and (Get-Date) -lt $limite) { Start-Sleep -Seconds 2 }
}
if (-not (En-Primer-Plano $Telefono)) { Fallar ($paquete + ' no esta en primer plano en ' + $Telefono + ' (foco: ' + (Foco-Actual $adb $Telefono) + ')') }

# 4. Medicion: logcat a un archivo mientras ocurre
New-Item -ItemType Directory -Force -Path (Join-Path $raiz 'build') | Out-Null
$sello = (Get-Date).ToString('yyyyMMdd-HHmmss')
if (-not $Salida) { $Salida = Join-Path $raiz ('build\fps-' + $Telefono + '-' + $sello + '.txt') }
$crudo = Join-Path $raiz ('build\logcat-' + $Telefono + '-' + $sello + '.txt')
$null = Adb-Texto $adb $Telefono @('logcat', '-c')
$temperaturaIni = Temperatura $Telefono
$inicio = Get-Date
$lc = Start-Process -FilePath $adb -ArgumentList @('-s', $Telefono, 'logcat', '-s', 'godot') -PassThru -NoNewWindow `
    -RedirectStandardOutput $crudo -RedirectStandardError ($crudo + '.err')
$perdioFoco = $false
for ($s = 5; $s -le $Segundos; $s += 5) {
    $falta = $inicio.AddSeconds($s) - (Get-Date)
    if ($falta.TotalSeconds -gt 0) { Start-Sleep -Milliseconds ([int]$falta.TotalMilliseconds) }
    if (-not (En-Primer-Plano $Telefono)) { $perdioFoco = $true; break }
}
$resto = $inicio.AddSeconds($Segundos) - (Get-Date)
if (-not $perdioFoco -and $resto.TotalSeconds -gt 0) { Start-Sleep -Milliseconds ([int]$resto.TotalMilliseconds) }
if (-not $perdioFoco -and -not (En-Primer-Plano $Telefono)) { $perdioFoco = $true }
Stop-Process -Id $lc.Id -Force -ErrorAction SilentlyContinue
$duracion = ((Get-Date) - $inicio).TotalSeconds
$temperaturaFin = Temperatura $Telefono
if ($perdioFoco) { Fallar ('la app perdio el primer plano durante la medicion; log en ' + $crudo) }

# 5. Resultado
$valores = @()
$lineasFps = @()
foreach ($linea in @(Get-Content -LiteralPath $crudo -ErrorAction SilentlyContinue)) {
    if ($linea -match '(?i)(\d+(?:[.,]\d+)?)\s*fps' -or $linea -match '(?i)fps\D{0,12}(\d+(?:[.,]\d+)?)') {
        $valores += [double]::Parse(($Matches[1] -replace ',', '.'), $inv)
        $lineasFps += $linea
    }
}
$minimo = [math]::Ceiling($Segundos / 2)
if ($valores.Count -lt $minimo) {
    Fallar ('solo ' + $valores.Count + ' lecturas de FPS en ' + $Segundos + ' s (minimo ' + $minimo + '): el APK no es del preset con --print-fps, o el formato cambio; log en ' + $crudo)
}
$media = ($valores | Measure-Object -Average).Average
$menor = ($valores | Measure-Object -Minimum).Minimum
$mayor = ($valores | Measure-Object -Maximum).Maximum
$orden = @($valores | Sort-Object)
$mediana = if ($orden.Count % 2 -eq 1) { $orden[($orden.Count - 1) / 2] } else { ($orden[$orden.Count / 2 - 1] + $orden[$orden.Count / 2]) / 2 }
$resumen = 'FPS telefono=' + $Telefono + ' modelo=' + $modelo + ' paquete=' + $paquete + ' apk_lastUpdateTime=' + $actualizado.ToString($fmt) +
    ' etiqueta=' + $(if ($Etiqueta) { $Etiqueta } else { 'sin_etiqueta' }) + ' ' + $condiciones +
    ' segundos=' + [int]$duracion + ' muestras=' + $valores.Count +
    ' media=' + $media.ToString('0.0', $inv) + ' mediana=' + ([double]$mediana).ToString('0.0', $inv) + ' minimo=' + $menor.ToString('0.0', $inv) + ' maximo=' + $mayor.ToString('0.0', $inv) +
    ' temp_ini=' + $temperaturaIni + ' temp_fin=' + $temperaturaFin + ' foco=ok fecha=' + (Get-Date).ToString($fmt)
Write-Output $resumen
Set-Content -LiteralPath $Salida -Value (@($resumen) + @($lineasFps | Select-Object -First 5 | ForEach-Object { 'crudo: ' + $_ }))
Write-Output ('MEDIR-FPS OK archivo=' + $Salida)
exit 0
