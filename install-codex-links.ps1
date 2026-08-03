$ErrorActionPreference = 'Stop'

$personalRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$personalSkillsRoot = Join-Path $personalRoot 'skills'
$codexSkillsRoot = 'C:\Users\marti\.agents\skills'

if (-not (Test-Path -LiteralPath $personalSkillsRoot -PathType Container)) {
  throw "No se encontro la carpeta de skills personales: $personalSkillsRoot"
}

$skills = @(
  Get-ChildItem -LiteralPath $personalSkillsRoot -Directory |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') -PathType Leaf } |
    Sort-Object Name
)

if ($skills.Count -eq 0) {
  throw "No se encontraron skills personales con SKILL.md en: $personalSkillsRoot"
}

New-Item -ItemType Directory -Force -Path $codexSkillsRoot | Out-Null

foreach ($skill in $skills) {
  $source = $skill.FullName
  $link = Join-Path $codexSkillsRoot $skill.Name
  $existing = Get-Item -Force -LiteralPath $link -ErrorAction SilentlyContinue

  if ($existing) {
    $targets = @(
      $existing.Target |
        Where-Object { $_ } |
        ForEach-Object { [IO.Path]::GetFullPath($_) }
    )
    $expected = [IO.Path]::GetFullPath($source)

    if ($existing.LinkType -eq 'Junction' -and $targets -contains $expected) {
      Write-Output "El enlace de Codex ya es correcto: $link"
      continue
    }

    if (-not ($existing.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
      throw "El destino existe y no es un enlace; no se modifico: $link"
    }

    Remove-Item -Force -LiteralPath $link
  }

  New-Item -ItemType Junction -Path $link -Target $source | Out-Null
  Write-Output "Enlace creado: $link -> $source"
}
