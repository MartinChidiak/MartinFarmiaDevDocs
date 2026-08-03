$ErrorActionPreference = 'Stop'

$personalRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$source = Join-Path $personalRoot 'skills\farmia-gestion-operativa'
$skillFile = Join-Path $source 'SKILL.md'
$codexSkillsRoot = 'C:\Users\marti\.agents\skills'
$link = Join-Path $codexSkillsRoot 'farmia-gestion-operativa'

if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) {
  throw "No se encontro la skill personal: $skillFile"
}

New-Item -ItemType Directory -Force -Path $codexSkillsRoot | Out-Null

$existing = Get-Item -Force -LiteralPath $link -ErrorAction SilentlyContinue
if ($existing) {
  $targets = @($existing.Target | ForEach-Object { [IO.Path]::GetFullPath($_) })
  $expected = [IO.Path]::GetFullPath($source)

  if ($existing.LinkType -eq 'Junction' -and $targets -contains $expected) {
    Write-Output "El enlace de Codex ya es correcto: $link"
    exit 0
  }

  if (-not ($existing.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
    throw "El destino existe y no es un enlace; no se modifico: $link"
  }

  Remove-Item -Force -LiteralPath $link
}

New-Item -ItemType Junction -Path $link -Target $source | Out-Null
Write-Output "Enlace creado: $link -> $source"
