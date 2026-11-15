# Reemplazos de texto en varios archivos, con vista previa, conteo y comprobacion de lo escrito.
# Sin -Aplicar solo muestra: no escribe nada. Con -Aplicar exige -Esperado <total de cambios que mostro la vista previa>.
# Uso:  .\herramientas\reemplazar.ps1 -Archivos 'docs\*.md' -Buscar 'texto viejo' -Poner 'texto nuevo'
#       .\herramientas\reemplazar.ps1 -Archivos docs\a.md,docs\b.md -Pares @(@('uno','1'),@('dos','2')) -Aplicar -Esperado 7
# -Archivos: rutas o comodines relativos a la raiz, separados por comas. Un patron sin archivos es error.
# -Pares: varias parejas @(buscar, poner), aplicadas en orden sobre el texto ya cambiado por las anteriores.
# -Regex: Buscar es una expresion regular (en Poner valen $1, $2) y no cambia los saltos de linea.
# Sin -Regex el texto es literal, distingue mayusculas y se adapta a los saltos de linea del archivo (LF o CRLF).
# Una pareja que no aparece en ningun archivo cancela todo (nada se escribe), salvo con -PermitirCero.
# Con -Aplicar se escribe todo o nada: antes de escribir guarda copia de cada archivo en .godot\reemplazar-respaldo\;
# despues relee cada archivo. Una escritura fallida (aunque sea a medias), una relectura distinta o Ctrl+C devuelven
# todos los archivos tocados. Si el proceso muere sin devolver, la carpeta de respaldo queda y la siguiente -Aplicar se niega.
# Ultima linea: REEMPLAZO archivos=<con cambios> cambios=<total> aplicado=<SI|NO|PARCIAL> verificado=<SI|NO|N/A>
# Sale con 0 si la vista previa o la aplicacion terminaron bien; 1 si algo no coincide (y no quedo nada cambiado);
# 2 si los parametros no valen o hay un respaldo pendiente; 3 si algun archivo no se pudo devolver (PARCIAL).
# Solo ASCII: powershell.exe 5.1 lee los .ps1 sin BOM como ANSI.
param(
    [Parameter(Mandatory = $true)][string[]]$Archivos,
    [string]$Buscar,
    [string]$Poner = '',
    [object[]]$Pares,
    [switch]$Regex,
    [switch]$Aplicar,
    [int]$Esperado = -1,
    [switch]$PermitirCero
)

$raiz = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Terminar([int]$archivos, [int]$cambios, [string]$aplicado, [string]$verificado, [int]$codigo, [string]$detalle) {
    if ($detalle) { Write-Output ('reemplazar: ' + $detalle) }
    Write-Output ('REEMPLAZO archivos={0} cambios={1} aplicado={2} verificado={3}' -f $archivos, $cambios, $aplicado, $verificado)
    exit $codigo
}

$parejas = @()
if ($PSBoundParameters.ContainsKey('Buscar')) { $parejas += , @($Buscar, $Poner) }
foreach ($p in @($Pares)) {
    if ($null -eq $p) { continue }
    $p = @($p)
    if ($p.Count -ne 2) { Terminar 0 0 'NO' 'N/A' 2 'cada pareja de -Pares lleva dos textos: buscar y poner' }
    $parejas += , @([string]$p[0], [string]$p[1])
}
if ($parejas.Count -eq 0) { Terminar 0 0 'NO' 'N/A' 2 'da -Buscar/-Poner o -Pares' }
foreach ($p in $parejas) { if ($p[0].Length -eq 0) { Terminar 0 0 'NO' 'N/A' 2 'un Buscar vacio no vale' } }
if ($Aplicar -and $Esperado -lt 0) { Terminar 0 0 'NO' 'N/A' 2 'con -Aplicar da -Esperado con el total de la vista previa' }

# Archivos: cada patron debe encontrar al menos uno.
$rutas = @()
foreach ($patron in @($Archivos | ForEach-Object { $_ -split ',' } | Where-Object { $_.Trim() -ne '' })) {
    $hallados = @(Get-ChildItem -Path (Join-Path $raiz $patron.Trim()) -File -ErrorAction SilentlyContinue)
    if ($hallados.Count -eq 0) { Terminar 0 0 'NO' 'N/A' 2 ('el patron no encontro archivos: ' + $patron) }
    foreach ($h in $hallados) { if ($rutas -notcontains $h.FullName) { $rutas += $h.FullName } }
}

function Contar([string]$texto, [string]$buscar) {
    if ($Regex) { return [regex]::Matches($texto, $buscar).Count }
    $n = 0; $pos = 0
    while (($pos = $texto.IndexOf($buscar, $pos, [System.StringComparison]::Ordinal)) -ge 0) { $n++; $pos += $buscar.Length }
    return $n
}

$totalPareja = New-Object int[] $parejas.Count
$plan = @()   # un elemento por archivo con cambios: Ruta, Original (bytes), Nuevo (texto), Cambios
foreach ($ruta in $rutas) {
    $bytes = [System.IO.File]::ReadAllBytes($ruta)
    if ($bytes -contains 0) { Write-Output ('omitido (binario): ' + $ruta.Substring($raiz.Length + 1)); continue }
    $texto = $utf8.GetString($bytes)
    $rel = $ruta.Substring($raiz.Length + 1)
    $crlf = (-not $Regex) -and $texto.Contains("`r`n")
    $cambios = 0
    for ($i = 0; $i -lt $parejas.Count; $i++) {
        $buscar = $parejas[$i][0]; $poner = $parejas[$i][1]
        if ($crlf) {
            $buscar = $buscar.Replace("`r`n", "`n").Replace("`n", "`r`n")
            $poner = $poner.Replace("`r`n", "`n").Replace("`n", "`r`n")
        }
        $n = Contar $texto $buscar
        if ($n -eq 0) { continue }
        # Vista previa: hasta 3 lineas por pareja y archivo (numero de linea segun el texto antes de esa pareja).
        $mostradas = 0; $pos = 0
        while ($mostradas -lt 3) {
            if ($Regex) { $m = [regex]::Match($texto.Substring($pos), $buscar); if (-not $m.Success) { break }; $donde = $pos + $m.Index; $largo = $m.Length }
            else { $donde = $texto.IndexOf($buscar, $pos, [System.StringComparison]::Ordinal); if ($donde -lt 0) { break }; $largo = $buscar.Length }
            $linea = ($texto.Substring(0, $donde) -split "`n").Count
            $ini = $texto.LastIndexOf("`n", [Math]::Max($donde - 1, 0)) + 1; if ($donde -eq 0) { $ini = 0 }
            $fin = $texto.IndexOf("`n", $donde); if ($fin -lt 0) { $fin = $texto.Length }
            $vista = $texto.Substring($ini, $fin - $ini).Trim()
            if ($vista.Length -gt 110) { $vista = $vista.Substring(0, 110) + '...' }
            Write-Output ('  {0}:{1} [pareja {2}] {3}' -f $rel, $linea, ($i + 1), $vista)
            $mostradas++; $pos = $donde + [Math]::Max($largo, 1)
            if ($pos -ge $texto.Length) { break }
        }
        if ($Regex) { $texto = [regex]::Replace($texto, $buscar, $poner) } else { $texto = $texto.Replace($buscar, $poner) }
        $totalPareja[$i] += $n; $cambios += $n
    }
    if ($cambios -gt 0) {
        $plan += , @{ Ruta = $ruta; Rel = $rel; Original = $bytes; Nuevo = $texto; Cambios = $cambios }
    }
}

$total = 0; foreach ($n in $totalPareja) { $total += $n }
for ($i = 0; $i -lt $parejas.Count; $i++) { Write-Output ('pareja {0}: {1} cambio(s)' -f ($i + 1), $totalPareja[$i]) }
$sinHallar = @(0..($parejas.Count - 1) | Where-Object { $totalPareja[$_] -eq 0 })
if ($sinHallar.Count -gt 0 -and -not $PermitirCero) {
    Terminar 0 $total 'NO' 'N/A' 1 ('NO: la pareja ' + (($sinHallar | ForEach-Object { $_ + 1 }) -join ', ') + ' no aparece en ningun archivo; no se escribio nada')
}
if (-not $Aplicar) {
    Terminar $plan.Count $total 'NO' 'N/A' 0 ('vista previa; para aplicar agrega -Aplicar -Esperado ' + $total)
}
if ($total -ne $Esperado) {
    Terminar $plan.Count $total 'NO' 'N/A' 1 ('se esperaban ' + $Esperado + ' cambios y hay ' + $total + '; no se escribio nada')
}

# Respaldo en disco ANTES de escribir: si el proceso muere a medias (ventana cerrada, kill), de aqui se restaura a mano.
$respaldoDir = Join-Path $raiz '.godot\reemplazar-respaldo'
if (Test-Path -LiteralPath $respaldoDir) {
    Terminar $plan.Count $total 'NO' 'N/A' 2 ('hay un respaldo de una aplicacion interrumpida en ' + $respaldoDir + ': copia cada archivo de lista.txt sobre el suyo y borra la carpeta')
}
try {
    New-Item -ItemType Directory -Force -Path $respaldoDir | Out-Null
    $lista = @()
    for ($k = 0; $k -lt $plan.Count; $k++) {
        [System.IO.File]::WriteAllBytes((Join-Path $respaldoDir ([string]$k + '.orig')), $plan[$k].Original)
        $lista += ([string]$k + '.orig = ' + $plan[$k].Rel)
    }
    [System.IO.File]::WriteAllLines((Join-Path $respaldoDir 'lista.txt'), [string[]]$lista)
}
catch {
    Remove-Item -LiteralPath $respaldoDir -Recurse -Force -ErrorAction SilentlyContinue
    Terminar $plan.Count $total 'NO' 'N/A' 1 ('no se pudo hacer el respaldo (' + $_.Exception.Message + '); no se escribio nada')
}

# Devuelve cada archivo a sus bytes originales y lo relee. Emite el nombre de cada uno que no volvio.
function Devolver($lista) {
    foreach ($a in $lista) {
        try {
            $ahora = [System.IO.File]::ReadAllBytes($a.Ruta)
            if ([Convert]::ToBase64String($ahora) -ceq [Convert]::ToBase64String($a.Original)) { continue }
            [System.IO.File]::WriteAllBytes($a.Ruta, $a.Original)
            $ahora = [System.IO.File]::ReadAllBytes($a.Ruta)
            if ([Convert]::ToBase64String($ahora) -cne [Convert]::ToBase64String($a.Original)) { $a.Rel }
        } catch { $a.Rel + ' (' + $_.Exception.Message + ')' }
    }
}

# Todo o nada: cada archivo se anota para devolver ANTES de escribirlo (si WriteAllBytes falla a medias, tambien vuelve),
# y una escritura fallida, una relectura distinta de lo calculado o un Ctrl+C devuelven todos los archivos tocados.
$escritos = @(); $completo = $false; $problema = 'interrumpido'; $verificado = 'N/A'; $sinVolver = @()
try {
    foreach ($a in $plan) {
        $escritos += , $a
        [System.IO.File]::WriteAllBytes($a.Ruta, $utf8.GetBytes($a.Nuevo))
    }
    $malos = @()
    foreach ($a in $plan) {
        $leido = $utf8.GetString([System.IO.File]::ReadAllBytes($a.Ruta))
        if ($leido -cne $a.Nuevo) { $malos += $a.Rel }
    }
    if ($malos.Count -gt 0) { $verificado = 'NO'; $problema = ('al releer no coincide lo escrito en ' + ($malos -join ', ')) }
    else { $verificado = 'SI'; $completo = $true }
}
catch { $problema = ('fallo al escribir o releer (' + $_.Exception.Message + ')') }
finally {
    if (-not $completo) { $sinVolver = @(Devolver $escritos) }
    if ($sinVolver.Count -eq 0) { Remove-Item -LiteralPath $respaldoDir -Recurse -Force -ErrorAction SilentlyContinue }
}
if ($completo) { Terminar $plan.Count $total 'SI' 'SI' 0 '' }
if ($sinVolver.Count -gt 0) {
    Terminar $plan.Count $total 'PARCIAL' $verificado 3 ($problema + '; NO SE DEVOLVIERON: ' + ($sinVolver -join ', ') + '. Copias en ' + $respaldoDir + ' (lista.txt dice cual es cual)')
}
Terminar $plan.Count $total 'NO' $verificado 1 ($problema + '; se devolvieron los ' + $escritos.Count + ' archivo(s) tocados y no queda nada cambiado')
