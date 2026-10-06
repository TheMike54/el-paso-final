# Hook PreToolUse (Bash|PowerShell|Monitor): impide que el asistente publique o reescriba el historial.
# Lee el JSON de stdin, localiza cada invocacion de git o gh y mira su subcomando real,
# saltando las opciones globales (-C ruta, -c k=v, --git-dir ...). Sale con 2 para bloquear.
# Solo ASCII: lo ejecuta powershell.exe 5.1.
$ErrorActionPreference = 'Stop'
try { $entrada = [Console]::In.ReadToEnd() | ConvertFrom-Json }
catch { [Console]::Error.WriteLine('sin-commit: no se pudo leer la entrada del hook'); exit 2 }
$orden = [string]$entrada.tool_input.command
if ([string]::IsNullOrWhiteSpace($orden)) { exit 0 }

$gitProhibidos = @('commit', 'push', 'merge', 'rebase', 'cherry-pick', 'revert', 'am', 'tag', 'reset', 'clean')
$gitConValor = @('-C', '-c', '--git-dir', '--work-tree', '--namespace', '--exec-path', '--config-env', '--super-prefix')
$ghGrupos = @('pr', 'issue', 'release', 'repo', 'label', 'workflow', 'run', 'secret', 'variable', 'ruleset')
$ghLectura = @('view', 'list', 'diff', 'checks', 'status', 'watch')

# Sin comillas y partido por espacios y separadores de shell: basta para ver "git ... <subcomando>".
$fichas = @(($orden -replace '["'']', ' ') -split '[\s;|&()`{}]+' | Where-Object { $_ })
$motivo = $null
for ($i = 0; $i -lt $fichas.Count -and -not $motivo; $i++) {
    $nombre = (($fichas[$i] -replace '\\', '/').Split('/')[-1]) -replace '\.exe$', ''
    if ($nombre -ne 'git' -and $nombre -ne 'gh') { continue }
    $j = $i + 1
    while ($j -lt $fichas.Count -and $fichas[$j].StartsWith('-')) {
        if (($gitConValor + @('-R', '--repo')) -ccontains $fichas[$j]) { $j += 2 } else { $j += 1 }
    }
    if ($j -ge $fichas.Count) { continue }
    $sub = $fichas[$j]
    $resto = @($fichas | Select-Object -Skip ($j + 1))
    if ($nombre -eq 'git' -and $gitProhibidos -ccontains $sub) {
        $inocuo = ($sub -eq 'tag' -and ($resto.Count -eq 0 -or $resto[0] -in @('-l', '--list', '-n'))) -or
                  ($sub -eq 'reset' -and $resto -notcontains '--hard') -or
                  ($sub -eq 'clean' -and ($resto -contains '-n' -or $resto -contains '--dry-run'))
        if (-not $inocuo) { $motivo = "git $sub" }
    }
    elseif ($nombre -eq 'gh') {
        $accion = if ($resto.Count -gt 0) { $resto[0] } else { '' }
        if ($ghGrupos -ccontains $sub -and $ghLectura -cnotcontains $accion) { $motivo = "gh $sub $accion" }
        elseif ($sub -eq 'api' -and $orden -match '(?i)(\s-X\s*|--method[= ]\s*)["'']?(POST|PUT|PATCH|DELETE)|\s(-f|-F|--field|--raw-field|--input)\b') { $motivo = 'gh api con escritura' }
    }
}
if ($motivo) {
    [Console]::Error.WriteLine("Bloqueado por el repo: '$motivo' lo ejecuta la persona, no el asistente. Entrega el bloque exacto de comandos para que lo corra. Si solo querias escribir o buscar ese texto, usa las herramientas de edicion o de busqueda.")
    exit 2
}
exit 0
