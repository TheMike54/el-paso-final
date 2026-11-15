# Exporta el APK, lo instala en el telefono pedido y comprueba que lo instalado es el APK nuevo.
# Uso: .\herramientas\instalar-apk.ps1 -Telefono S503124334437 [-Preset Desarrollo] [-BorrarPartidas]
#   -Telefono       Serie(s) de adb. Sin ella solo se sigue si hay UN telefono conectado; con dos o mas, falla.
#   -Preset         Preset de export_presets.cfg, por nombre (Desarrollo). El paquete sale del preset.
#   -Salida         Ruta del APK; por omision build\<preset en minusculas>.apk.
#   -BorrarPartidas Borra partida_*.json y prueba_*.json (y su .bak) de files/ en el telefono, no los ajustes. Apagado por omision.
#   -SinExportar    Instala el APK que ya hay, pero solo si no es mas viejo que el ultimo cambio.
#   -SoloVerificar  Revisa adb, telefonos y preset y sale; no exporta ni instala.
# Pasos: telefonos listos (offline: reintenta) -> borra el APK viejo -> exporta con tiempo limite -> gradlew --stop ->
# APK mas nuevo que el inicio de la exportacion y que el ultimo cambio -> install -r (reintenta) -> lastUpdateTime
# del telefono de hace instantes. Imprime una linea INSTALADO por telefono y termina con "INSTALAR-APK OK" (salida 0)
# o "INSTALAR-APK FALLA" (salida 1). El detalle queda tambien en build\instalaciones.log.
# Solo ASCII: debe correr igual en powershell.exe 5.1 y en pwsh 7. Sin $ErrorActionPreference = 'Stop' alrededor de ejecutables.
param(
    [string[]]$Telefono = @(),
    [string]$Preset = 'Desarrollo',
    [string]$Salida = '',
    [switch]$BorrarPartidas,
    [switch]$SinExportar,
    [switch]$SoloVerificar,
    [int]$MinutosExportacion = 15
)

$raiz = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'telefono-comun.ps1')
$script:exporto = $false

function Parar-Gradle {
    if (-not $script:exporto) { return }
    $gradlew = Join-Path $raiz 'android\build\gradlew.bat'
    if (-not (Test-Path -LiteralPath $gradlew)) { Write-Output 'aviso  no hay android\build\gradlew.bat: no se paro el demonio de gradle'; return }
    Push-Location (Split-Path -Parent $gradlew)
    $null = @(& $gradlew --stop 2>&1)
    $codigo = $LASTEXITCODE
    Pop-Location
    if ($codigo -eq 0) { Write-Output 'ok     demonio de gradle detenido (gradlew --stop)' }
    else { Write-Output 'aviso  gradlew --stop fallo: el demonio puede seguir vivo y bloquear archivos' }
}

function Fallar([string]$motivo) {
    Parar-Gradle
    Write-Output ('INSTALAR-APK FALLA ' + $motivo)
    exit 1
}

# Fecha y archivo del ultimo cambio que puede entrar al APK (sin .import, .uid ni documentos, que Godot o la persona tocan sin cambiar el juego).
function Ultimo-Cambio {
    $mayor = [datetime]::MinValue
    $archivo = ''
    $ignorar = @('.import', '.uid', '.ps1', '.md', '.guion', '.esperado')
    $lista = @()
    foreach ($c in @('nucleo', 'contenido', 'interfaz', 'mapa', 'herramientas')) {
        $ruta = Join-Path $raiz $c
        if (Test-Path -LiteralPath $ruta) { $lista += @(Get-ChildItem -LiteralPath $ruta -Recurse -File) }
    }
    foreach ($s in @('project.godot', 'export_presets.cfg', 'default_bus_layout.tres')) {
        $ruta = Join-Path $raiz $s
        if (Test-Path -LiteralPath $ruta) { $lista += @(Get-Item -LiteralPath $ruta) }
    }
    foreach ($f in $lista) {
        if ($ignorar -contains $f.Extension -or $f.Name -eq 'funciones.json') { continue }
        if ($f.LastWriteTime -gt $mayor) { $mayor = $f.LastWriteTime; $archivo = $f.FullName.Substring($raiz.Length).TrimStart('\') }
    }
    return @{ Fecha = $mayor; Archivo = $archivo }
}

function Borrar-Partidas([string]$adb, [string]$serie, [string]$paquete) {
    $null = Adb-Texto $adb $serie @('shell', ('am force-stop ' + $paquete))
    $lista = Adb-Texto $adb $serie @('shell', ('run-as ' + $paquete + ' ls files'))
    if ($script:CodigoAdb -ne 0) { Fallar ($serie + ': run-as no pudo listar files/ (el APK no es de depuracion?): ' + $lista) }
    $borradas = 0
    foreach ($nombre in ($lista -split "`n")) {
        $n = $nombre.Trim()
        if ($n -notmatch '^(partida|prueba)_[A-Za-z0-9_-]+\.json(\.bak)?$') { continue }
        $null = Adb-Texto $adb $serie @('shell', ('run-as ' + $paquete + ' rm -f files/' + $n))
        if ($script:CodigoAdb -ne 0) { Fallar ($serie + ': no se pudo borrar files/' + $n) }
        $borradas++
    }
    $resto = Adb-Texto $adb $serie @('shell', ('run-as ' + $paquete + ' ls files'))
    foreach ($nombre in ($resto -split "`n")) {
        if ($nombre.Trim() -match '^(partida|prueba)_') { Write-Output ('aviso  ' + $serie + ': queda files/' + $nombre.Trim() + ' (no coincide con el patron de borrado)') }
    }
    return $borradas
}

# 1. adb
$adb = Buscar-Adb
if (-not $adb) { Fallar 'no hay adb (Android SDK, platform-tools)' }

# 2. Preset y paquete
$cfg = Join-Path $raiz 'export_presets.cfg'
if (-not (Test-Path -LiteralPath $cfg)) { Fallar ('no existe ' + $cfg) }
$info = Leer-Preset $cfg $Preset
if (-not $info.Paquete) { Fallar ("no hay preset '" + $Preset + "' con package/unique_name. Presets: " + ($info.Nombres -join ', ')) }
$paquete = $info.Paquete
if ($paquete -notmatch '^[A-Za-z0-9_.]+$') { Fallar ("package/unique_name raro: '" + $paquete + "'") }
if (-not $Salida) { $Salida = 'build\' + ($Preset.ToLower() -replace '[^a-z0-9]+', '-') + '.apk' }
$apk = if ([System.IO.Path]::IsPathRooted($Salida)) { $Salida } else { Join-Path $raiz $Salida }
Write-Output ("ok     preset '" + $Preset + "' paquete " + $paquete + " apk " + $apk)

# 3. Telefonos: se resuelven y se dejan listos ANTES de exportar, para no gastar minutos si no hay a quien instalar
$conectados = @(Leer-Telefonos $adb)
$series = @($Telefono | Where-Object { $_ })
if ($series.Count -eq 0) {
    $listos = @($conectados | Where-Object { $_.Estado -eq 'device' })
    if ($conectados.Count -eq 1 -and $listos.Count -eq 1) {
        $series = @($listos[0].Serie)
        Write-Output ('aviso  sin -Telefono; hay uno solo conectado: ' + $series[0])
    }
    else {
        $texto = if ($conectados.Count -eq 0) { 'ninguno' } else { ($conectados | ForEach-Object { $_.Serie + '=' + $_.Estado }) -join ', ' }
        Fallar ('pasa -Telefono <serie>. Conectados: ' + $texto)
    }
}
foreach ($serie in $series) {
    if (-not (Esperar-Telefono $adb $serie)) { Fallar $script:Motivo }
    Write-Output ('ok     ' + $serie + ' (' + (Modelo-Telefono $adb $serie) + ') listo')
}
if ($SoloVerificar) {
    Write-Output ('INSTALAR-APK VERIFICADO telefonos=' + $series.Count)
    exit 0
}

# 4. Exportar
$inicio = Get-Date
if ($SinExportar) {
    if (-not (Test-Path -LiteralPath $apk)) { Fallar ('-SinExportar y no existe ' + $apk) }
}
else {
    $godot = $env:GODOT_PATH
    if (-not $godot -or -not (Test-Path -LiteralPath $godot)) { Fallar 'GODOT_PATH no apunta al ejecutable de consola de Godot 4.7.2' }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $apk) | Out-Null
    foreach ($viejo in @($apk, ($apk + '.idsig'))) {
        if (Test-Path -LiteralPath $viejo) { Remove-Item -LiteralPath $viejo -Force }
    }
    $registro = Join-Path $raiz 'build\exportacion.log'
    $inicio = Get-Date
    $script:exporto = $true
    $p = Start-Process -FilePath $godot -PassThru -NoNewWindow -RedirectStandardOutput $registro -RedirectStandardError ($registro + '.err') `
        -ArgumentList @('--headless', '--path', ('"' + $raiz + '"'), '--export-debug', ('"' + $Preset + '"'), ('"' + $apk + '"'))
    if (-not $p.WaitForExit($MinutosExportacion * 60000)) {
        Stop-Process -Id $p.Id -Force
        Fallar ('la exportacion paso de ' + $MinutosExportacion + ' min (Godot esperando al demonio de gradle?); detalle en ' + $registro)
    }
    Parar-Gradle
    $script:exporto = $false
}

# 5. El APK es de esta exportacion y no es mas viejo que el ultimo cambio
if (-not (Test-Path -LiteralPath $apk)) { Fallar ('la exportacion no genero ' + $apk + '; revisa build\exportacion.log') }
$info = Get-Item -LiteralPath $apk
if ($info.Length -le 0) { Fallar ('el APK esta vacio: ' + $apk) }
if (-not $SinExportar -and $info.LastWriteTime -lt $inicio) { Fallar ('el APK (' + $info.LastWriteTime + ') es anterior al inicio de la exportacion (' + $inicio + ')') }
$cambio = Ultimo-Cambio
if ($info.LastWriteTime -lt $cambio.Fecha) {
    Fallar ('el APK (' + $info.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss') + ') es mas viejo que el ultimo cambio (' + $cambio.Fecha.ToString('yyyy-MM-dd HH:mm:ss') + ', ' + $cambio.Archivo + ')')
}
$fmt = 'yyyy-MM-dd HH:mm:ss'
Write-Output ('ok     APK ' + $info.LastWriteTime.ToString($fmt) + ' (' + [math]::Round($info.Length / 1MB, 1) + ' MB); ultimo cambio ' + $cambio.Fecha.ToString($fmt) + ' ' + $cambio.Archivo)

# 6. Instalar y comprobar, telefono por telefono
$registroInstalaciones = Join-Path $raiz 'build\instalaciones.log'
foreach ($serie in $series) {
    if (-not (Esperar-Telefono $adb $serie)) { Fallar $script:Motivo }
    $listo = $false
    $ultimo = ''
    for ($intento = 1; $intento -le 3; $intento++) {
        $ultimo = Adb-Texto $adb $serie @('install', '-r', $apk)
        if ($ultimo -match 'Success') { $listo = $true; break }
        Write-Output ('aviso  install en ' + $serie + ' intento ' + $intento + ': ' + (($ultimo -split "`n") | Select-Object -Last 1))
        if ($ultimo -match 'UPDATE_INCOMPATIBLE|VERSION_DOWNGRADE|signatures do not match') { break }
        if (-not (Esperar-Telefono $adb $serie)) { Fallar $script:Motivo }
    }
    if (-not $listo) { Fallar ($serie + ': adb install no dio Success: ' + $ultimo + ' (firma distinta: el APK de otra maquina no se instala encima; el script nunca desinstala)') }

    $actualizado = Ultima-Actualizacion $adb $serie $paquete
    if (-not $actualizado) { Fallar ($serie + ': no se pudo leer lastUpdateTime de ' + $paquete) }
    $ahora = Hora-Telefono $adb $serie
    if (-not $ahora) { $ahora = Get-Date }
    $edad = ($ahora - $actualizado).TotalSeconds
    if ($edad -lt -10 -or $edad -gt 180) {
        Fallar ($serie + ': lastUpdateTime ' + $actualizado.ToString($fmt) + ' no es de hace instantes (hora del telefono ' + $ahora.ToString($fmt) + '): no hay APK nuevo')
    }

    $borradas = 0
    if ($BorrarPartidas) { $borradas = Borrar-Partidas $adb $serie $paquete }
    $linea = 'INSTALADO telefono=' + $serie + ' modelo=' + (Modelo-Telefono $adb $serie) + ' paquete=' + $paquete + ' preset=' + $Preset +
        ' lastUpdateTime=' + $actualizado.ToString($fmt) + ' hora_telefono=' + $ahora.ToString($fmt) +
        ' apk_fecha=' + $info.LastWriteTime.ToString($fmt) + ' partidas_borradas=' + $(if ($BorrarPartidas) { $borradas } else { 'no_pedido' })
    Write-Output $linea
    Add-Content -LiteralPath $registroInstalaciones -Value ((Get-Date).ToString($fmt) + ' ' + $linea)
}

Write-Output ('INSTALAR-APK OK telefonos=' + $series.Count)
exit 0
