param(
  [string]$FarmiaRepo,
  [string]$ConfigPath,
  [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$docsRoot = [IO.Path]::GetFullPath((Split-Path -Parent $MyInvocation.MyCommand.Path))
. (Join-Path $docsRoot 'scripts\farmia-devdocs-common.ps1')
$settings = Get-FarmiaLocalSettings -DocsRoot $docsRoot -FarmiaRepo $FarmiaRepo -ConfigPath $ConfigPath
$archiveRoot = Join-Path $docsRoot 'worktree-notes'
$allowedFiles = @(
  'tasks\todo.gestion-agro.local.md',
  'tasks\lessons.gestion-agro.local.md'
)

if (-not (Test-Path -LiteralPath $settings.FarmiaRepo -PathType Container)) {
  throw "No se encontro el checkout principal: $($settings.FarmiaRepo)"
}

$worktreeLines = & git -C $settings.FarmiaRepo worktree list --porcelain
if ($LASTEXITCODE -ne 0) {
  throw 'No se pudo obtener la lista de worktrees.'
}
$worktrees = @(
  $worktreeLines |
    Where-Object { $_ -like 'worktree *' } |
    ForEach-Object { [IO.Path]::GetFullPath($_.Substring(9)) }
)

foreach ($worktree in $worktrees) {
  $insidePrimary = Test-FarmiaPathInside -Path $worktree -Root $settings.FarmiaRepo
  $insideWorktrees = Test-FarmiaPathInside -Path $worktree -Root $settings.WorktreesRoot
  if (-not ($insidePrimary -or $insideWorktrees)) {
    throw "Worktree fuera de las raices configuradas: $worktree"
  }

  $archiveName = Split-Path -Leaf $worktree
  $destinationRoot = Join-Path $archiveRoot $archiveName
  $copied = 0

  foreach ($relativePath in $allowedFiles) {
    $source = Join-Path $worktree $relativePath
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { continue }

    $destination = Join-Path $destinationRoot (Split-Path -Leaf $relativePath)
    if ($WhatIf) {
      Write-Output "Se respaldaria: $source -> $destination"
      $copied++
      continue
    }

    New-Item -ItemType Directory -Force -Path $destinationRoot | Out-Null
    Copy-Item -Force -LiteralPath $source -Destination $destination
    $sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $source).Hash
    $destinationHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $destination).Hash
    if ($sourceHash -ne $destinationHash) {
      throw "El respaldo no coincide: $destination"
    }
    $copied++
    Write-Output "Respaldado: $source -> $destination"
  }

  if ($copied -eq 0) {
    Write-Output "Sin notas locales para respaldar: $worktree"
  }
}
