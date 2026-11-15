# Bateria de los hooks de .claude/hooks/: les pasa entradas simuladas por stdin, igual que Claude Code.
# sin-commit.ps1: compara el codigo de salida (2 = bloquea, 0 = deja pasar). No ejecuta ninguna orden.
# al-compactar.ps1: que su salida quepa en 10000 caracteres y traiga lo decidido de cada plan activo.
# Imprime solo los casos que fallan y un resumen; sale con 1 si alguno falla. Solo ASCII.
$hooks = Join-Path (Split-Path -Parent $PSScriptRoot) '.claude\hooks'
$hook = Join-Path $hooks 'sin-commit.ps1'

$bloquea = @(
    'git -C "carpeta con espacios" push',
    'git -c "demo.valor=texto con espacios" merge main',
    'git -C "carpeta con espacios" tag v1',
    'git commit -m x',
    'git -C . commit --allow-empty -m x',
    'git -c user.name=x commit -m y',
    "git 'push'",
    'git --git-dir .git push',
    '& git commit -m x',
    '"C:\Program Files\Git\cmd\git.exe" push',
    "bash -c 'git commit -m x'",
    'git status; git push',
    'git push origin main',
    'git add . && git commit -m x',
    'cd nucleo; git commit -m x',
    'git.exe commit -m x',
    'GIT_AUTHOR_NAME=x git commit -m y',
    'git --work-tree . --git-dir .git commit -m x',
    'git merge chore/setup',
    'git rebase main',
    'git tag -a parcial-1 -m x',
    'git cherry-pick abc123',
    'git revert HEAD',
    'git am parche.patch',
    'git reset --hard HEAD~1',
    'git clean -fd',
    'gh pr create --fill',
    'gh -R x/y pr create',
    'gh pr merge 1 --squash',
    'gh pr review 1 --approve',
    'gh issue create -t x',
    'gh repo create x/y --public',
    'gh label create qa-pending',
    'gh release create v1',
    'gh workflow run ci.yml',
    'gh ruleset delete 1',
    'gh api -X POST repos/x/y/labels',
    'gh api --method PATCH repos/x/y',
    'gh api repos/x/y/rulesets --input ruleset.json',
    'gh api repos/x/y/labels -f name=z'
)
$deja = @(
    'git status',
    'git log --grep=push',
    'git log origin/main -i --grep=Co-Authored-By --format=%h',
    'git tag -l',
    'git tag',
    'git merge-base main HEAD',
    'git stash push',
    'git add herramientas/validar.ps1',
    'git reset HEAD x',
    'git clean -n -d',
    'git diff --stat',
    'git show HEAD --stat',
    'git fetch origin',
    'git checkout -b chore/setup',
    'git config core.hooksPath herramientas/githooks',
    'git check-ignore -v CLAUDE.local.md',
    'gh pr view 1',
    'gh pr diff 1',
    'gh pr checks 1',
    'gh label list -R x/y',
    'gh run list --limit 5',
    'gh repo view x/y --json name',
    'gh api repos/x/y',
    '& $env:GODOT_PATH --headless --path . --import',
    '.\herramientas\validar.ps1 -SinImportar'
)

function Salida([string]$texto) {
    $texto | powershell.exe -NoProfile -ExecutionPolicy Bypass -File $hook 2>$null | Out-Null
    return $LASTEXITCODE
}
function Entrada([string]$orden) {
    return (@{ tool_name = 'Bash'; tool_input = @{ command = $orden } } | ConvertTo-Json -Compress)
}

$fallos = 0
$total = 0
foreach ($orden in $bloquea) {
    $total++
    if ((Salida (Entrada $orden)) -ne 2) { $fallos++; Write-Output ("FALLO  deberia bloquear: " + $orden) }
}
foreach ($orden in $deja) {
    $total++
    if ((Salida (Entrada $orden)) -ne 0) { $fallos++; Write-Output ("FALLO  deberia dejar pasar: " + $orden) }
}
# Una entrada que no es JSON bloquea; una herramienta sin orden deja pasar.
$total++
if ((Salida 'esto no es json') -ne 2) { $fallos++; Write-Output 'FALLO  deberia bloquear: entrada ilegible' }
$total++
if ((Salida '{"tool_name":"Bash","tool_input":{}}') -ne 0) { $fallos++; Write-Output 'FALLO  deberia dejar pasar: orden vacia' }

function Respuesta([string]$script, [string]$texto) {
    $sale = $texto | powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script 2>$null
    return [pscustomobject]@{ codigo = $LASTEXITCODE; texto = (@($sale) -join "`n") }
}
function Fallo([string]$mensaje) { $script:fallos++; Write-Output ("FALLO  " + $mensaje) }

# al-compactar.ps1 sobre el repo real: cabe en 10000 caracteres y trae la seccion de decisiones de cada plan activo.
$total++
$r = Respuesta (Join-Path $hooks 'al-compactar.ps1') '{}'
if ($r.codigo -ne 0 -or $r.texto.Length -ge 10000 -or $r.texto -notmatch '--- ESTADO.md ---') { Fallo ("al-compactar: salida " + $r.texto.Length + " caracteres, codigo " + $r.codigo) }
foreach ($plan in @(Get-ChildItem -LiteralPath (Join-Path (Split-Path -Parent $PSScriptRoot) 'planes\activos') -Filter '*.md' -File -ErrorAction SilentlyContinue)) {
    if (Select-String -LiteralPath $plan.FullName -Pattern '^## (Decidido|Decisiones cerradas)' -Quiet) {
        $total++
        if ($r.texto -notmatch [regex]::Escape("--- planes/activos/$($plan.Name): ")) { Fallo ("al-compactar no trae lo decidido de " + $plan.Name) }
    }
}

Write-Output ("PRUEBAS hooks total=$total fallos=$fallos")
if ($fallos -gt 0) { exit 1 }
exit 0
