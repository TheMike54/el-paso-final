# Revisa el entorno de un clon: Godot 4.7.2 y GODOT_PATH, identidad de git, hook de git,
# archivos locales ignorados y version de Claude Code. Activa el hook de git y agrega las
# lineas de exclude si faltan. Termina con "ENTORNO OK" (salida 0) o "ENTORNO FALLA" (salida 1).
# Solo ASCII: debe correr igual en powershell.exe 5.1 y en pwsh 7.
$raiz = Split-Path -Parent $PSScriptRoot
$script:fallos = 0
function Bien([string]$texto) { Write-Output ("ok     " + $texto) }
function Mal([string]$texto) { $script:fallos++; Write-Output ("FALLA  " + $texto) }

# 1. Godot
$godot = $env:GODOT_PATH
if (-not $godot -or -not (Test-Path -LiteralPath $godot)) {
    Mal 'GODOT_PATH no apunta al ejecutable de consola de Godot 4.7.2 (setx GODOT_PATH "<ruta>" y abrir otra terminal)'
}
else {
    $version = [string](& $godot --version 2>$null | Select-Object -First 1)
    if ($version -like '4.7.2.stable*') { Bien ("Godot " + $version) }
    else { Mal ("Godot es '" + $version + "' y el proyecto exige 4.7.2.stable") }
}

# 2. Git: identidad con la que quedan firmados los commits
$nombre = [string](git -C $raiz config user.name)
$correo = [string](git -C $raiz config user.email)
if ($nombre -and $correo) { Bien ("git user.name='" + $nombre + "' user.email='" + $correo + "'") }
else { Mal 'falta git config user.name o user.email (el correo debe ser el de la cuenta de GitHub)' }

# 3. Hook de git que rechaza la atribucion de asistentes (core.hooksPath no viaja al clonar)
$rutaHooks = 'herramientas/githooks'
if ([string](git -C $raiz config core.hooksPath) -ne $rutaHooks) {
    git -C $raiz config core.hooksPath $rutaHooks
}
if (([string](git -C $raiz config core.hooksPath) -eq $rutaHooks) -and (Test-Path -LiteralPath (Join-Path $raiz 'herramientas\githooks\commit-msg'))) {
    Bien ("core.hooksPath=" + $rutaHooks)
}
else { Mal 'no se pudo activar el hook de git (git config core.hooksPath herramientas/githooks)' }

# 4. Archivos locales: ignorados y sin versionar
$exclude = [string](git -C $raiz rev-parse --git-path info/exclude)
if ($exclude -and -not [System.IO.Path]::IsPathRooted($exclude)) { $exclude = Join-Path $raiz $exclude }
foreach ($local in @('CLAUDE.local.md', '.claude/settings.local.json')) {
    git -C $raiz check-ignore -q $local
    if ($LASTEXITCODE -ne 0 -and $exclude) {
        Add-Content -LiteralPath $exclude -Value $local
        git -C $raiz check-ignore -q $local
    }
    $ignorado = ($LASTEXITCODE -eq 0)
    $versionado = [string](git -C $raiz ls-files -- $local)
    if ($ignorado -and -not $versionado) { Bien ($local + " ignorado y sin versionar") }
    else { Mal ($local + " no esta ignorado o esta versionado") }
}

# 5. Claude Code (opcional para correr el juego; si esta instalado, la version minima importa)
$claude = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claude) { Write-Output 'aviso  Claude Code no esta instalado: no hace falta para correr el proyecto' }
else {
    $texto = [string](claude --version 2>$null | Select-Object -First 1)
    if ($texto -match '(\d+)\.(\d+)\.(\d+)') {
        $actual = [version]($Matches[1] + '.' + $Matches[2] + '.' + $Matches[3])
        if ($actual -ge [version]'2.1.288') { Bien ("Claude Code " + $actual) }
        else { Mal ("Claude Code " + $actual + " es anterior a 2.1.288 (claude update)") }
    }
    else { Mal 'no se pudo leer la version de Claude Code (claude --version)' }
}

if ($script:fallos -eq 0) { Write-Output 'ENTORNO OK'; exit 0 }
Write-Output ("ENTORNO FALLA (" + $script:fallos + ")")
exit 1
