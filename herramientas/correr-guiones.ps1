# Corre los guiones de herramientas/guiones/ como el CI (ci.yml, paso "Input scripts") e imprime solo los que fallan.
# Sin parametros corre todos; con -Guiones nucleo/tienda,mapa/mapa_cuentas, solo esos (sin extension).
# Un guion esta bien si su salida tiene una linea "GUION OK" y ninguna "SCRIPT ERROR" ni "ERROR:". Sale con 0 solo si MALOS=0.
# Una sola corrida a la vez: un candado en .godot\correr-guiones.lock; si otra corrida lo tiene, sale con 3.
# El log completo de cada guion que falla queda en .godot\guiones-fallidos\<bloque>_<nombre>-<fecha>.log.
# Solo ASCII: powershell.exe 5.1 lee los .ps1 sin BOM como ANSI. En serie: los guiones comparten archivos de user://.
param([string[]]$Guiones)

$godot = $env:GODOT_PATH
if (-not $godot -or -not (Test-Path -LiteralPath $godot)) {
    Write-Output 'correr-guiones: define GODOT_PATH con la ruta del ejecutable de consola de Godot 4.7.2'
    exit 2
}
$raiz = Split-Path -Parent $PSScriptRoot
$carpeta = Join-Path $raiz 'herramientas\guiones'
$log = Join-Path $raiz '.godot\correr-guiones.log'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $log) | Out-Null

# Candado: se abre el archivo sin compartirlo. Si otra corrida lo tiene abierto, falla y esta se niega.
# Si una corrida muere sin borrarlo, el sistema suelta el archivo y la siguiente puede abrirlo.
$archivoCandado = Join-Path $raiz '.godot\correr-guiones.lock'
try {
    $candado = [System.IO.File]::Open($archivoCandado, [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
} catch [System.IO.IOException] {
    Write-Output ('correr-guiones: ya hay otra corrida en marcha (candado ' + $archivoCandado + '); esperar a que termine')
    exit 3
}

$codigoSalida = 1
try {
    # Lista de rutas relativas a la raiz, con "/". "powershell.exe -File" pasa "a,b" como un solo texto: se parte por comas.
    $rutas = @()
    if ($Guiones -and $Guiones.Count -gt 0) {
        foreach ($g in @($Guiones | ForEach-Object { $_ -split ',' })) {
            $nombre = $g.Trim().Replace('\', '/')
            if ($nombre -eq '') { continue }
            if ($nombre.EndsWith('.guion')) { $nombre = $nombre.Substring(0, $nombre.Length - 6) }
            $rutas += ('herramientas/guiones/' + $nombre + '.guion')
        }
    } else {
        $rutas = @(Get-ChildItem -LiteralPath $carpeta -Recurse -Filter '*.guion' | Sort-Object FullName |
            ForEach-Object { $_.FullName.Substring($raiz.Length + 1).Replace('\', '/') })
    }

    $ok = 0
    $malos = 0
    foreach ($rel in $rutas) {
        if (-not (Test-Path -LiteralPath (Join-Path $raiz $rel))) {
            $malos++
            Write-Output ('MALO ' + $rel)
            Write-Output '    > el guion no existe'
            continue
        }
        # cmd /c une stdout y stderr en un archivo sin que PowerShell 5.1 convierta stderr en errores; se lee como UTF-8.
        cmd /c "`"$godot`" --headless --path `"$raiz`" --fixed-fps 60 --quit-after 7200 -- --guion=$rel > `"$log`" 2>&1"
        $lineas = @(Get-Content -LiteralPath $log -Encoding UTF8)
        $terminado = @($lineas | Where-Object { $_ -cmatch '^GUION OK' }).Count -gt 0
        $errores = @($lineas | Where-Object { $_ -cmatch 'SCRIPT ERROR|^\s*ERROR:' }).Count -gt 0
        if ($terminado -and -not $errores) {
            $ok++
            continue
        }
        $malos++
        Write-Output ('MALO ' + $rel)
        $relevantes = @($lineas | Where-Object { $_ -cmatch 'FALLO|GUION FALLA|SCRIPT ERROR|ERROR:|^\s+at: ' })
        if ($relevantes.Count -eq 0) { $relevantes = @('sin GUION OK ni lineas de error: no termino antes de --quit-after') }
        $relevantes | Select-Object -First 12 | ForEach-Object { Write-Output ('    > ' + $_.Trim()) }
        # El log se pisa con el guion siguiente: el de un fallo se guarda entero para poder investigar uno
        # intermitente (#56, docs/errores/2026-11-22-guiones-intermitentes.md).
        $fallidos = Join-Path $raiz '.godot\guiones-fallidos'
        New-Item -ItemType Directory -Force -Path $fallidos | Out-Null
        $copia = Join-Path $fallidos ('{0}-{1}.log' -f ($rel -replace '^herramientas/guiones/', '' -replace '[/\\]', '_' -replace '\.guion$', ''), (Get-Date -Format 'yyyyMMdd-HHmmss'))
        Copy-Item -LiteralPath $log -Destination $copia -Force
        Write-Output ('    > log completo: ' + $copia)
    }

    Write-Output ('RESUMEN total={0} OK={1} MALOS={2}' -f $rutas.Count, $ok, $malos)
    $codigoSalida = 0
    if ($malos -gt 0) { $codigoSalida = 1 }
} finally {
    $candado.Dispose()
    Remove-Item -LiteralPath $archivoCandado -Force -ErrorAction SilentlyContinue
}
exit $codigoSalida
