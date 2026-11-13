$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $taskRoot

$taskStatusJson = & supabase status --workdir supabase/.temp/preprod -o json
if ($LASTEXITCODE -ne 0) {
    throw 'La preproduction Supabase locale est indisponible. Demarre Docker et la preproduction locale.'
}
try {
    $taskStatus = $taskStatusJson | ConvertFrom-Json
} catch {
    throw 'Impossible de lire la configuration Supabase locale.'
}
if ($taskStatus.API_URL -ne 'http://127.0.0.1:54321' -or
    [string]::IsNullOrWhiteSpace($taskStatus.ANON_KEY)) {
    throw 'La configuration Supabase ne correspond pas a la preproduction locale attendue.'
}

$taskAdb = $null
foreach ($taskSdk in @($env:ANDROID_SDK_ROOT, $env:ANDROID_HOME, (Join-Path $env:LOCALAPPDATA 'Android/Sdk'))) {
    if ($taskSdk) {
        $taskCandidate = Join-Path $taskSdk 'platform-tools/adb.exe'
        if (Test-Path -LiteralPath $taskCandidate) {
            $taskAdb = $taskCandidate
            break
        }
    }
}
if (-not $taskAdb) {
    $taskCommand = Get-Command adb -ErrorAction SilentlyContinue
    if ($taskCommand) { $taskAdb = $taskCommand.Source }
}
if (-not $taskAdb) { throw 'ADB est introuvable. Verifie ton installation du SDK Android.' }

$taskDevicesOutput = & $taskAdb devices
if ($LASTEXITCODE -ne 0) { throw 'Impossible de lister les appareils Android.' }
$taskDevices = @($taskDevicesOutput | ForEach-Object {
    if ($_ -match '^(\S+)\s+device\s*$') { $Matches[1] }
})
if ($taskDevices.Count -eq 0) {
    throw 'Demarre un emulateur ou connecte un appareil Android avant de lancer la preproduction.'
}
foreach ($taskDevice in $taskDevices) {
    $taskMappings = & $taskAdb -s $taskDevice reverse --list
    if ($LASTEXITCODE -ne 0) { throw "Impossible de lire les connexions ADB de $taskDevice." }
    $taskExisting = @($taskMappings | Where-Object { $_ -match '(?:^|\s)tcp:54321\s+\S+\s*$' })
    if ($taskExisting.Count -gt 0 -and @($taskExisting | Where-Object { $_ -notmatch 'tcp:54321\s+tcp:54321\s*$' }).Count -gt 0) {
        throw "Le port Android 54321 est deja utilise par une autre connexion sur $taskDevice."
    }
    if ($taskExisting.Count -eq 0) {
        $null = & $taskAdb -s $taskDevice reverse tcp:54321 tcp:54321
        if ($LASTEXITCODE -ne 0) { throw "Impossible de connecter $taskDevice a la preproduction locale." }
    }
}

$taskDefines = @{
    BICOUNT_LOCAL_PREPROD = 'true'
    BICOUNT_LOCAL_ANON_KEY = $taskStatus.ANON_KEY
    BICOUNT_SYNC_JOURNAL = 'true'
} | ConvertTo-Json -Compress
$taskDefinesPath = Join-Path $taskRoot 'supabase/.temp/bicount_preprod_defines.json'
[System.IO.File]::WriteAllText($taskDefinesPath, $taskDefines, [System.Text.UTF8Encoding]::new($false))
Write-Output 'Preproduction locale prete. VS Code peut demarrer le build Android.'
