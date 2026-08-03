$ErrorActionPreference = 'Stop'

$personalRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$hooksPath = Join-Path $personalRoot 'git-hooks\farmia'
$repo = 'C:\Users\marti\OneDrive\Farmia\farmia_app'
$hook = Join-Path $hooksPath 'pre-commit'

if (-not (Test-Path -LiteralPath $hook -PathType Leaf)) {
  throw "No se encontro el hook: $hook"
}

if (-not (Test-Path -LiteralPath (Join-Path $repo '.git'))) {
  throw "No se encontro el checkout principal: $repo"
}

$gitHooksPath = $hooksPath.Replace('\', '/')
& git -C $repo config --local core.hooksPath $gitHooksPath
if ($LASTEXITCODE -ne 0) {
  throw 'No se pudo configurar core.hooksPath.'
}

Write-Output "Proteccion Git local instalada: $gitHooksPath"
