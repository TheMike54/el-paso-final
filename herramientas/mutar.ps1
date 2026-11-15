# Aplica UNA mutacion a un archivo, corre el caso que debe detectarla y restaura el archivo siempre.
# Uso:  .\herramientas\mutar.ps1 -Archivo nucleo\tienda.gd -Buscar 'autoguardar()' -Poner 'pass' -Guiones nucleo/tienda
#       .\herramientas\mutar.ps1 -Archivo nucleo\jugador.gd -Buscar 'texto' -Poner 'otro' -Validar
# -Guiones: los de correr-guiones.ps1 (sin extension). -Validar: el caso es validar.ps1. Se da uno de los dos.
# Sin -SinBase corre el caso antes de mutar: si ya falla sin mutar, la mutacion no prueba nada (INVALIDA).
# Ultima linea: MUTACION resultado=<MATADA|SOBREVIVE|INVALIDA|NO_APLICA|BLOQUEADA> restaurado=<SI|NO|NO_TOCADO> arbol=<IGUAL|CAMBIADO|SIN_GIT>
# Sale con 0 si MATADA (el caso detecto la mutacion) y restaurado; 1 si SOBREVIVE (el caso no detecta nada);
# 2 si INVALIDA, NO_APLICA o BLOQUEADA; 3 si el archivo no quedo restaurado.
# MATADA exige que el caso imprima un fallo propio (FALLO, GUION FALLA, SCRIPT ERROR, ERROR:); un guion que no
# existe o que no termino no cuenta como detectada.
# Una sola corrida de Godot a la vez: se niega si hay un proceso Godot vivo o si otra mutacion tiene el candado.
# Si correr-guiones.ps1 sale con 3 (otra corrida tiene su candado), el caso es INVALIDA: esperar y repetir.
# Solo ASCII: powershell.exe 5.1 lee los .ps1 sin BOM como ANSI.
param(
    [Parameter(Mandatory = $true)][string]$Archivo,
    [Parameter(Mandatory = $true)][string]$Buscar,
    [string]$Poner = '',
    [string[]]$Guiones,
    [switch]$Validar,
    [switch]$SinBase,
    [switch]$IgnorarProcesos
)

$raiz = Split-Path -Parent $PSScriptRoot
$godotDir = Join-Path $raiz '.godot'
$candado = Join-Path $godotDir 'mutar.lock'
$respaldo = Join-Path $godotDir 'mutar-respaldo.orig'
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Terminar([string]$resultado, [string]$restaurado, [string]$arbol, [int]$codigo, [string]$detalle) {
    if ($detalle) { Write-Output ('mutar: ' + $detalle) }
    Write-Output ('MUTACION resultado={0} restaurado={1} arbol={2}' -f $resultado, $restaurado, $arbol)
    exit $codigo
}

function Estado-Git {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git) { return $null }
    $r = & git -C $raiz status --porcelain 2>&1
    if ($LASTEXITCODE -ne 0) { return $null }
    return (@($r) -join "`n")
}

# Corre el caso y devuelve @{ Estado = PASA|FALLA|INVALIDA; Detalle = texto }. Coincidencia exacta y con mayusculas.
function Correr-Caso {
    if ($Validar) {
        $salida = @(& (Join-Path $PSScriptRoot 'validar.ps1') 2>&1 | ForEach-Object { [string]$_ })
        $codigo = $LASTEXITCODE
        $ok = @($salida | Where-Object { $_ -cmatch '^OK  VALIDACION archivos=\d+ fallos=0$' }).Count
        $falla = @($salida | Where-Object { $_ -cmatch '^FALLO |SCRIPT ERROR|^\s*ERROR:|^VALIDACION archivos=\d+ fallos=[1-9]\d*$' }).Count
        if ($codigo -eq 0 -and $ok -eq 1 -and $falla -eq 0) { return @{ Estado = 'PASA'; Detalle = '' } }
        if ($codigo -eq 1 -and $falla -gt 0) { return @{ Estado = 'FALLA'; Detalle = (@($salida | Select-Object -First 3) -join ' | ') } }
        return @{ Estado = 'INVALIDA'; Detalle = ('validar.ps1 salio con ' + $codigo + ' sin linea OK ni fallo propio') }
    }
    $pedidos = @($Guiones | ForEach-Object { $_ -split ',' } | Where-Object { $_.Trim() -ne '' })
    $salida = @(& (Join-Path $PSScriptRoot 'correr-guiones.ps1') -Guiones $pedidos 2>&1 | ForEach-Object { [string]$_ })
    $codigo = $LASTEXITCODE
    if ($codigo -eq 3) { return @{ Estado = 'INVALIDA'; Detalle = 'correr-guiones.ps1 salio con 3: otra corrida tiene su candado (.godot/correr-guiones.lock); esperar a que termine y repetir' } }
    $resumen = @($salida | Where-Object { $_ -cmatch '^RESUMEN total=\d+ OK=\d+ MALOS=\d+$' })
    if ($resumen.Count -ne 1) { return @{ Estado = 'INVALIDA'; Detalle = 'no hay una sola linea RESUMEN' } }
    $m = [regex]::Match($resumen[0], '^RESUMEN total=(\d+) OK=(\d+) MALOS=(\d+)$')
    $total = [int]$m.Groups[1].Value; $ok = [int]$m.Groups[2].Value; $malos = [int]$m.Groups[3].Value
    if ($total -ne $pedidos.Count) { return @{ Estado = 'INVALIDA'; Detalle = ('se pidieron ' + $pedidos.Count + ' guiones y el resumen dice ' + $total) } }
    if ($codigo -eq 0 -and $malos -eq 0 -and $ok -eq $total) { return @{ Estado = 'PASA'; Detalle = '' } }
    $propios = @($salida | Where-Object { $_ -cmatch '^\s+> .*(FALLO|GUION FALLA|SCRIPT ERROR|ERROR:)' })
    if ($codigo -eq 1 -and $malos -gt 0 -and $propios.Count -gt 0) { return @{ Estado = 'FALLA'; Detalle = $propios[0].Trim() } }
    return @{ Estado = 'INVALIDA'; Detalle = 'MALO sin fallo propio del caso (el guion no existe o no termino)' }
}

if ((-not $Validar -and -not $Guiones) -or ($Validar -and $Guiones)) {
    Terminar 'BLOQUEADA' 'NO_TOCADO' 'SIN_GIT' 2 'da -Guiones <lista> o -Validar, uno solo'
}
$ruta = [System.IO.Path]::GetFullPath((Join-Path $raiz $Archivo))
if (-not $ruta.StartsWith($raiz + [System.IO.Path]::DirectorySeparatorChar) -or $ruta -like '*\.git\*') {
    Terminar 'BLOQUEADA' 'NO_TOCADO' 'SIN_GIT' 2 'el archivo debe estar dentro del proyecto y fuera de .git'
}
if (-not (Test-Path -LiteralPath $ruta -PathType Leaf)) {
    Terminar 'NO_APLICA' 'NO_TOCADO' 'SIN_GIT' 2 ('no existe ' + $Archivo)
}
if (-not $IgnorarProcesos) {
    $vivos = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like 'Godot*' })
    if ($vivos.Count -gt 0) {
        Terminar 'BLOQUEADA' 'NO_TOCADO' 'SIN_GIT' 2 ('hay ' + $vivos.Count + ' proceso(s) Godot vivos (' + $vivos[0].ProcessName + '): una corrida a la vez')
    }
}

# Candado: abierto sin compartir mientras dura la mutacion. Si el archivo existe y se puede abrir, el dueno murio sin restaurar.
New-Item -ItemType Directory -Force -Path $godotDir | Out-Null
$flujo = $null
try { $flujo = New-Object System.IO.FileStream($candado, 'CreateNew', 'ReadWrite', 'None') }
catch {
    if (Test-Path -LiteralPath $candado) {
        try {
            $viejo = [System.IO.File]::ReadAllText($candado)
            Terminar 'BLOQUEADA' 'NO_TOCADO' 'SIN_GIT' 2 ('un candado viejo indica una mutacion sin restaurar (' + $viejo.Trim() + '). Copia el respaldo sobre ese archivo y borra ' + $candado)
        } catch [System.IO.IOException] {
            Terminar 'BLOQUEADA' 'NO_TOCADO' 'SIN_GIT' 2 'otra mutacion esta corriendo'
        }
    }
    Terminar 'BLOQUEADA' 'NO_TOCADO' 'SIN_GIT' 2 ('no se pudo crear el candado: ' + $_.Exception.Message)
}

$original = [System.IO.File]::ReadAllBytes($ruta)
$sha = [System.Security.Cryptography.SHA256]::Create()
$hashOriginal = [BitConverter]::ToString($sha.ComputeHash($original))
[System.IO.File]::WriteAllBytes($respaldo, $original)
$info = $utf8.GetBytes($Archivo + ' respaldo=' + $respaldo)
$flujo.Write($info, 0, $info.Length); $flujo.Flush()

$resultado = 'INVALIDA'; $codigo = 2; $detalle = ''
$gitAntes = Estado-Git
$mutado = $false
try {
    $texto = $utf8.GetString($original)
    $buscar = $Buscar; $poner = $Poner
    if ($texto.Contains("`r`n")) {
        $buscar = $buscar.Replace("`r`n", "`n").Replace("`n", "`r`n")
        $poner = $poner.Replace("`r`n", "`n").Replace("`n", "`r`n")
    }
    $veces = 0; $pos = 0
    while (($pos = $texto.IndexOf($buscar, $pos, [System.StringComparison]::Ordinal)) -ge 0) { $veces++; $pos += $buscar.Length }
    if ($buscar.Length -eq 0 -or $veces -eq 0) { $resultado = 'NO_APLICA'; $detalle = 'el texto a mutar no aparece en el archivo' }
    elseif ($veces -gt 1) { $resultado = 'NO_APLICA'; $detalle = ('el texto aparece ' + $veces + ' veces; amplialo para que sea unico') }
    elseif ($buscar -ceq $poner) { $resultado = 'NO_APLICA'; $detalle = 'Buscar y Poner son iguales' }
    else {
        $base = $null
        if (-not $SinBase) {
            $base = Correr-Caso
            if ($base.Estado -ne 'PASA') { $resultado = 'INVALIDA'; $detalle = ('el caso no pasa sin mutar (' + $base.Estado + '): ' + $base.Detalle) }
        }
        if ($SinBase -or $base.Estado -eq 'PASA') {
            $donde = $texto.IndexOf($buscar, [System.StringComparison]::Ordinal)
            $nuevo = $texto.Substring(0, $donde) + $poner + $texto.Substring($donde + $buscar.Length)
            $mutado = $true
            [System.IO.File]::WriteAllBytes($ruta, $utf8.GetBytes($nuevo))
            $r = Correr-Caso
            switch ($r.Estado) {
                'FALLA'    {
                    $resultado = 'MATADA'; $codigo = 0; $detalle = ('el caso detecto la mutacion: ' + $r.Detalle)
                    if ($r.Detalle -cmatch 'SCRIPT ERROR|Parse Error') { $detalle += ' (AVISO: parece error de sintaxis; la mutacion debe cambiar el comportamiento, no romper el parseo)' }
                }
                'PASA'     { $resultado = 'SOBREVIVE'; $codigo = 1; $detalle = 'el caso pasa con el archivo roto: no prueba lo que dice' }
                default    { $resultado = 'INVALIDA'; $detalle = ('la corrida con la mutacion no es valida: ' + $r.Detalle) }
            }
        }
    }
}
catch { $resultado = 'INVALIDA'; $codigo = 2; $detalle = 'error en mutar.ps1: ' + $_.Exception.Message }
finally {
    $restaurado = 'NO_TOCADO'
    if ($mutado) {
        try {
            [System.IO.File]::WriteAllBytes($ruta, $original)
            $hashAhora = [BitConverter]::ToString($sha.ComputeHash([System.IO.File]::ReadAllBytes($ruta)))
            if ($hashAhora -eq $hashOriginal) { $restaurado = 'SI' } else { $restaurado = 'NO' }
        } catch { $restaurado = 'NO' }
    }
    $flujo.Dispose()
    if ($restaurado -ne 'NO') {
        Remove-Item -LiteralPath $candado -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $respaldo -Force -ErrorAction SilentlyContinue
    }
}
$gitDespues = Estado-Git
if ($null -eq $gitAntes -or $null -eq $gitDespues) { $arbol = 'SIN_GIT' }
elseif ($gitAntes -ceq $gitDespues) { $arbol = 'IGUAL' } else { $arbol = 'CAMBIADO' }
if ($restaurado -eq 'NO') { $codigo = 3; $detalle = 'NO SE RESTAURO ' + $Archivo + ': copia en ' + $respaldo + ' (el candado queda hasta que la restaures)' }
Terminar $resultado $restaurado $arbol $codigo $detalle
