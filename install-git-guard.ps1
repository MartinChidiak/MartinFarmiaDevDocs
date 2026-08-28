param(
  [string]$FarmiaRepo,
  [string]$ConfigPath
)

$ErrorActionPreference = 'Stop'
$docsRoot = [IO.Path]::GetFullPath((Split-Path -Parent $MyInvocation.MyCommand.Path))
. (Join-Path $docsRoot 'scripts\farmia-devdocs-common.ps1')
$settings = Get-FarmiaLocalSettings -DocsRoot $docsRoot -FarmiaRepo $FarmiaRepo -ConfigPath $ConfigPath
$hooksPath = Join-Path $docsRoot 'git-hooks\farmia'
$hook = Join-Path $hooksPath 'pre-commit'

if (-not (Test-Path -LiteralPath $hook -PathType Leaf)) {
  throw "No se encontro el hook: $hook"
}
if (-not (Test-Path -LiteralPath $settings.FarmiaRepo -PathType Container)) {
  throw "No se encontro el checkout de FarmIA: $($settings.FarmiaRepo)"
}

& git -C $settings.FarmiaRepo rev-parse --is-inside-work-tree 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
  throw "La ruta no es un checkout Git: $($settings.FarmiaRepo)"
}

$gitHooksPath = $hooksPath.Replace('\', '/')
& git -C $settings.FarmiaRepo config --local core.hooksPath $gitHooksPath
if ($LASTEXITCODE -ne 0) {
  throw 'No se pudo configurar core.hooksPath.'
}

Write-Output "Proteccion Git local instalada en $($settings.FarmiaRepo): $gitHooksPath"
