# Junta las funciones de adb de instalar-apk.ps1 y medir-fps.ps1; algunas las usa uno solo. No se corre solo: se carga con ". .\telefono-comun.ps1".
# Ninguna imprime: devuelven el resultado y dejan el motivo de un fallo en $script:Motivo; quien las llama imprime.
# Solo ASCII: debe correr igual en powershell.exe 5.1 y en pwsh 7.

function Buscar-Adb {
    $comando = Get-Command adb -ErrorAction SilentlyContinue
    if ($comando) { return $comando.Source }
    $sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
    if (Test-Path -LiteralPath $sdk) { return $sdk }
    return $null
}

# Un objeto por linea de "adb devices": Serie y Estado (device, offline, unauthorized...).
function Leer-Telefonos([string]$adb) {
    $lista = @()
    foreach ($linea in @(& $adb devices 2>&1)) {
        if ([string]$linea -match '^(\S+)\s+(device|offline|unauthorized|recovery|sideload|bootloader|no permissions.*)\s*$') {
            $lista += [pscustomobject]@{ Serie = $Matches[1]; Estado = $Matches[2] }
        }
    }
    return $lista
}

# Ejecuta "adb -s <serie> <argumentos>" y devuelve el texto (salida y errores juntos). El codigo queda en $script:CodigoAdb.
# Los argumentos de "shell" van como una sola cadena y con comillas simples por dentro, para que PowerShell no los parta.
function Adb-Texto([string]$adb, [string]$serie, [string[]]$argumentos) {
    $salida = & $adb -s $serie @argumentos 2>&1
    $script:CodigoAdb = $LASTEXITCODE
    return (($salida | ForEach-Object { [string]$_ }) -join "`n").Trim()
}

# $true cuando el telefono queda en estado "device". Offline: adb reconnect offline y espera; sin autorizar o sin aparecer: falla.
function Esperar-Telefono([string]$adb, [string]$serie, [int]$intentos = 3) {
    $script:Motivo = ''
    for ($i = 1; $i -le $intentos; $i++) {
        $t = @(Leer-Telefonos $adb) | Where-Object { $_.Serie -eq $serie } | Select-Object -First 1
        if ($t -and $t.Estado -eq 'device') { return $true }
        if ($t -and $t.Estado -eq 'unauthorized') {
            $script:Motivo = $serie + ' no autorizo la depuracion USB (hay que aceptarla en la pantalla del telefono)'
            return $false
        }
        $script:Motivo = $serie + ' esta ' + $(if ($t) { "'" + $t.Estado + "'" } else { 'ausente de adb devices' })
        if ($t -and $t.Estado -eq 'offline') { & $adb reconnect offline 2>&1 | Out-Null }
        Start-Sleep -Seconds 4
    }
    return $false
}

function Modelo-Telefono([string]$adb, [string]$serie) {
    $m = Adb-Texto $adb $serie @('shell', 'getprop ro.product.model')
    if ($script:CodigoAdb -eq 0 -and $m) { return $m }
    return 'desconocido'
}

# Hora del telefono como DateTime, o $null.
function Hora-Telefono([string]$adb, [string]$serie) {
    $texto = Adb-Texto $adb $serie @('shell', "date '+%Y-%m-%d %H:%M:%S'")
    $f = [datetime]::MinValue
    if ([datetime]::TryParseExact($texto, 'yyyy-MM-dd HH:mm:ss', [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::None, [ref]$f)) { return $f }
    return $null
}

# lastUpdateTime del paquete instalado (DateTime), o $null si no esta instalado o no se pudo leer.
function Ultima-Actualizacion([string]$adb, [string]$serie, [string]$paquete) {
    $texto = Adb-Texto $adb $serie @('shell', ('dumpsys package ' + $paquete))
    if ($texto -match 'lastUpdateTime=(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})') {
        return [datetime]::ParseExact($Matches[1], 'yyyy-MM-dd HH:mm:ss', [Globalization.CultureInfo]::InvariantCulture)
    }
    return $null
}

# Lee export_presets.cfg: devuelve @{ Nombres = <lista>; Paquete = <package/unique_name del preset pedido o $null> }.
function Leer-Preset([string]$archivo, [string]$nombre) {
    $nombres = @{}
    $paquetes = @{}
    $seccion = ''
    foreach ($linea in Get-Content -LiteralPath $archivo) {
        if ($linea -match '^\[(.+)\]\s*$') { $seccion = $Matches[1]; continue }
        if ($seccion -match '^preset\.(\d+)$') {
            $n = $Matches[1]
            if ($linea -match '^name="(.*)"\s*$') { $nombres[$n] = $Matches[1] }
        }
        elseif ($seccion -match '^preset\.(\d+)\.options$') {
            $n = $Matches[1]
            if ($linea -match '^package/unique_name="(.*)"\s*$') { $paquetes[$n] = $Matches[1] }
        }
    }
    $paquete = $null
    foreach ($n in $nombres.Keys) {
        if ($nombres[$n] -eq $nombre -and $paquetes.ContainsKey($n)) { $paquete = $paquetes[$n] }
    }
    return @{ Nombres = @($nombres.Values); Paquete = $paquete }
}

# La linea de mCurrentFocus (o '' si no hay), para saber que app esta en primer plano.
function Foco-Actual([string]$adb, [string]$serie) {
    $texto = Adb-Texto $adb $serie @('shell', 'dumpsys window')
    foreach ($linea in ($texto -split "`n")) {
        if ($linea -match 'mCurrentFocus=') { return $linea.Trim() }
    }
    return ''
}
