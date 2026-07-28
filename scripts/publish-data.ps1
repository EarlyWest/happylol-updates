param(
    [string]$DataRoot = 'D:\codex\LOLreserve2\happylol本地解锁版\runtime-next\HappyLOLData',
    [string]$Repository = 'EarlyWest/happylol-updates',
    [string[]]$GameVersions = @('auto')
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$gh = 'C:\Program Files\GitHub CLI\gh.exe'
$stamp = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')
$tag = "data-$stamp"
$archiveName = "HappyLOLData-$stamp.zip"
$archive = Join-Path $env:TEMP $archiveName

if (-not (Test-Path -LiteralPath $DataRoot -PathType Container)) {
    throw "Data root does not exist: $DataRoot"
}
if (-not (Test-Path -LiteralPath $gh -PathType Leaf)) {
    throw "GitHub CLI does not exist: $gh"
}
if (Test-Path -LiteralPath $archive) { Remove-Item -LiteralPath $archive -Force }

Compress-Archive -Path (Join-Path $DataRoot '*') -DestinationPath $archive -CompressionLevel Optimal
$hash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
$size = (Get-Item -LiteralPath $archive).Length

if ($GameVersions.Count -eq 1 -and $GameVersions[0] -eq 'auto') {
    $metadata = Join-Path (Split-Path -Parent $DataRoot) '..\app-qt-next\Game\code-metadata.json'
    $detected = $null
    if (Test-Path -LiteralPath $metadata) {
        $json = Get-Content -LiteralPath $metadata -Raw | ConvertFrom-Json
        $detected = $json.version
    }
    $GameVersions = @($(if ($detected) { $detected } else { 'current' }))
}

& $gh release create $tag $archive --repo $Repository --title "HappyLOL data $stamp" `
    --notes "Automated HappyLOLData baseline package."
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$manifest = [ordered]@{
    schema = 2
    data_version = $stamp
    game_versions = $GameVersions
    min_backend_api = 1
    published_at = (Get-Date).ToUniversalTime().ToString('o')
    full_archive = [ordered]@{
        url = "https://github.com/$Repository/releases/download/$tag/$archiveName"
        sha256 = $hash
        size = $size
    }
    files = @()
}
$manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $repoRoot 'manifest.json') -Encoding utf8

git -C $repoRoot add manifest.json
git -C $repoRoot commit -m "Publish HappyLOLData $stamp"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
git -C $repoRoot push origin main
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item -LiteralPath $archive -Force
Write-Host "Published $tag ($size bytes, SHA-256 $hash)"
