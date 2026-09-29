param(
  [string]$DestinationRoot
)

$ErrorActionPreference = 'Stop'
$docsRoot = [IO.Path]::GetFullPath((Split-Path -Parent $MyInvocation.MyCommand.Path))
$skillsRoot = Join-Path $docsRoot 'skills'

if (-not $env:USERPROFILE) {
  throw 'USERPROFILE no esta definido.'
}
if (-not $DestinationRoot) {
  $DestinationRoot = Join-Path $env:USERPROFILE '.agents\skills'
}
if (-not (Test-Path -LiteralPath $skillsRoot -PathType Container)) {
  throw "No se encontro la carpeta de skills: $skillsRoot"
}

$skills = @(
  Get-ChildItem -LiteralPath $skillsRoot -Directory |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') -PathType Leaf } |
    Sort-Object Name
)
if ($skills.Count -eq 0) {
  throw "No se encontraron skills con SKILL.md en: $skillsRoot"
}

New-Item -ItemType Directory -Force -Path $DestinationRoot | Out-Null

foreach ($skill in $skills) {
  $source = [IO.Path]::GetFullPath($skill.FullName).TrimEnd('\')
  $link = Join-Path $DestinationRoot $skill.Name
  $existing = Get-Item -Force -LiteralPath $link -ErrorAction SilentlyContinue

  if ($existing) {
    $targets = @($existing.Target | Where-Object { $_ } | ForEach-Object {
      try { [IO.Path]::GetFullPath($_).TrimEnd('\') } catch { $_ }
    })
    if (($existing.Attributes -band [IO.FileAttributes]::ReparsePoint) -and
        $targets -contains $source) {
      Write-Output "El enlace de Codex ya es correcto: $link"
      continue
    }
    if (-not ($existing.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
      throw "El destino existe y no es un enlace; no se modifico: $link"
    }
    # Borra solo el enlace: Remove-Item pide confirmacion en PowerShell 5.1
    # y con -Recurse podria vaciar el destino.
    [IO.Directory]::Delete($link)
  }

  New-Item -ItemType Junction -Path $link -Target $source | Out-Null
  Write-Output "Enlace creado: $link -> $source"
}
