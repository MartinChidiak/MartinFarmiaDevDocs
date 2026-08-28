Set-StrictMode -Version 2.0

function Get-FarmiaTomlString {
  param(
    [Parameter(Mandatory = $true)][string]$Content,
    [Parameter(Mandatory = $true)][string]$Section,
    [Parameter(Mandatory = $true)][string]$Key
  )

  $sectionPattern = '(?ms)^\s*\[' + [Regex]::Escape($Section) +
    '\]\s*$\r?\n(?<body>.*?)(?=^\s*\[|\z)'
  $sectionMatch = [Regex]::Match($Content, $sectionPattern)
  if (-not $sectionMatch.Success) { return $null }

  $keyPattern = '(?m)^\s*' + [Regex]::Escape($Key) +
    '\s*=\s*"(?<value>(?:\\.|[^"\\])*)"\s*(?:#.*)?$'
  $keyMatch = [Regex]::Match($sectionMatch.Groups['body'].Value, $keyPattern)
  if (-not $keyMatch.Success) { return $null }

  return $keyMatch.Groups['value'].Value.Replace('\\', '\').Replace('\"', '"')
}

function Get-FarmiaLocalSettings {
  param(
    [Parameter(Mandatory = $true)][string]$DocsRoot,
    [string]$FarmiaRepo,
    [string]$ConfigPath
  )

  $resolvedDocsRoot = [IO.Path]::GetFullPath($DocsRoot)
  if (-not $ConfigPath) {
    $ConfigPath = Join-Path $resolvedDocsRoot 'config\farmia-project.config.toml'
  }

  $config = ''
  if (Test-Path -LiteralPath $ConfigPath -PathType Leaf) {
    $config = Get-Content -LiteralPath $ConfigPath -Raw -Encoding utf8
  }

  if (-not $FarmiaRepo) {
    $FarmiaRepo = Get-FarmiaTomlString -Content $config -Section 'paths' -Key 'farmia_app'
  }
  if (-not $FarmiaRepo) {
    $FarmiaRepo = Join-Path (Split-Path -Parent $resolvedDocsRoot) 'farmia_app'
  }

  $worktrees = Get-FarmiaTomlString -Content $config -Section 'paths' -Key 'worktrees'
  if (-not $worktrees) {
    $worktrees = Join-Path (Split-Path -Parent $resolvedDocsRoot) 'worktrees'
  }

  $machineId = Get-FarmiaTomlString -Content $config -Section 'machine' -Key 'id'
  if (-not $machineId) { $machineId = $env:COMPUTERNAME }

  [PSCustomObject]@{
    MachineId = $machineId
    DocsRoot = $resolvedDocsRoot
    FarmiaRepo = [IO.Path]::GetFullPath($FarmiaRepo)
    WorktreesRoot = [IO.Path]::GetFullPath($worktrees)
    ConfigPath = [IO.Path]::GetFullPath($ConfigPath)
    ConfigExists = Test-Path -LiteralPath $ConfigPath -PathType Leaf
  }
}

function Test-FarmiaPathInside {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Root
  )

  $fullPath = [IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
  $fullRoot = [IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
  return $fullPath.Equals($fullRoot, [StringComparison]::OrdinalIgnoreCase) -or
    $fullPath.StartsWith(
      $fullRoot + [IO.Path]::DirectorySeparatorChar,
      [StringComparison]::OrdinalIgnoreCase
    )
}
