$ErrorActionPreference = 'Stop'

$farmiaRoot = [IO.Path]::GetFullPath('C:\Users\marti\OneDrive\Farmia')
$primaryRepo = Join-Path $farmiaRoot 'farmia_app'
$archiveRoot = Join-Path $farmiaRoot 'personal-codex\worktree-notes'
$allowedFiles = @(
  'tasks\todo.gestion-agro.local.md',
  'tasks\lessons.gestion-agro.local.md'
)

if (-not (Test-Path -LiteralPath (Join-Path $primaryRepo '.git'))) {
  throw "No se encontro el checkout principal: $primaryRepo"
}

$worktreeLines = & git -C $primaryRepo worktree list --porcelain
if ($LASTEXITCODE -ne 0) {
  throw 'No se pudo obtener la lista de worktrees.'
}

$worktrees = @(
  $worktreeLines |
    Where-Object { $_ -like 'worktree *' } |
    ForEach-Object { [IO.Path]::GetFullPath($_.Substring(9)) }
)

foreach ($worktree in $worktrees) {
  if (-not $worktree.StartsWith(
      $farmiaRoot + [IO.Path]::DirectorySeparatorChar,
      [StringComparison]::OrdinalIgnoreCase
    )) {
    throw "Worktree fuera de FarmIA: $worktree"
  }

  $archiveName = Split-Path -Leaf $worktree
  $destinationRoot = Join-Path $archiveRoot $archiveName
  $copied = 0

  foreach ($relativePath in $allowedFiles) {
    $source = Join-Path $worktree $relativePath
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
      continue
    }

    New-Item -ItemType Directory -Force -Path $destinationRoot | Out-Null
    $destination = Join-Path $destinationRoot (Split-Path -Leaf $relativePath)
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
