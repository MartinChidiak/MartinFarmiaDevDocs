param(
  [string]$AgentsPath
)

$ErrorActionPreference = 'Stop'
$docsRoot = [IO.Path]::GetFullPath((Split-Path -Parent $MyInvocation.MyCommand.Path))
$templatePath = Join-Path $docsRoot 'config\codex-global-agents.example.md'

if (-not $env:USERPROFILE) {
  throw 'USERPROFILE no esta definido.'
}
if (-not $AgentsPath) {
  $AgentsPath = Join-Path $env:USERPROFILE '.codex\AGENTS.md'
}
if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
  throw "No se encontro la plantilla: $templatePath"
}

$begin = '<!-- BEGIN FARMIA DEVDOCS MANAGED -->'
$end = '<!-- END FARMIA DEVDOCS MANAGED -->'
$managed = (Get-Content -LiteralPath $templatePath -Raw -Encoding utf8).
  Replace('{{FARMIA_DOCS_ROOT}}', $docsRoot.TrimEnd('\'))
$managedBlock = $managed.TrimEnd()
$existing = if (Test-Path -LiteralPath $AgentsPath -PathType Leaf) {
  Get-Content -LiteralPath $AgentsPath -Raw -Encoding utf8
} else { '' }

$pattern = '(?s)' + [Regex]::Escape($begin) + '.*?' + [Regex]::Escape($end)
$matches = [Regex]::Matches($existing, $pattern)
if ($matches.Count -gt 1) {
  throw "Hay mas de un bloque FarmIA administrado en: $AgentsPath"
}

if ($matches.Count -eq 1) {
  $updated = [Regex]::Replace($existing, $pattern, [Text.RegularExpressions.MatchEvaluator]{ param($match) $managedBlock })
} elseif ([string]::IsNullOrWhiteSpace($existing)) {
  $updated = $managedBlock + [Environment]::NewLine
} else {
  $updated = $existing.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine +
    $managedBlock + [Environment]::NewLine
}

if (($updated -replace "`r`n", "`n") -eq ($existing -replace "`r`n", "`n")) {
  Write-Output "El router global ya es correcto: $AgentsPath"
  exit 0
}

$parent = Split-Path -Parent $AgentsPath
New-Item -ItemType Directory -Force -Path $parent | Out-Null
Set-Content -LiteralPath $AgentsPath -Value $updated -Encoding utf8 -NoNewline
Write-Output "Router global actualizado: $AgentsPath"
