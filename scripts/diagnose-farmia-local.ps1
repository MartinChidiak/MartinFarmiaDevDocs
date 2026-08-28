param(
  [string]$FarmiaRepo,
  [string]$ConfigPath,
  [int]$HttpTimeoutSeconds = 3
)

$ErrorActionPreference = 'Continue'
$docsRoot = [IO.Path]::GetFullPath((Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)))
. (Join-Path $docsRoot 'scripts\farmia-devdocs-common.ps1')
$settings = Get-FarmiaLocalSettings -DocsRoot $docsRoot -FarmiaRepo $FarmiaRepo -ConfigPath $ConfigPath

function Write-DiagnosticSection([string]$Title) {
  Write-Output ''
  Write-Output "== $Title"
}

function Invoke-GitReadOnly {
  param([string[]]$Arguments)
  $output = & git -C $settings.FarmiaRepo @Arguments 2>&1
  if ($LASTEXITCODE -ne 0) { return "No disponible: $($output -join ' ')" }
  return $output
}

function Test-HttpEndpoint {
  param([string]$Name, [string]$Url)
  try {
    $response = Invoke-WebRequest -UseBasicParsing -Uri $Url -Method Get -TimeoutSec $HttpTimeoutSeconds
    [PSCustomObject]@{ Name = $Name; Url = $Url; Result = "HTTP $($response.StatusCode)" }
  } catch {
    $status = if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
      "HTTP $([int]$_.Exception.Response.StatusCode)"
    } else { 'sin respuesta' }
    [PSCustomObject]@{ Name = $Name; Url = $Url; Result = $status }
  }
}

Write-Output 'Diagnostico FarmIA local (solo lectura)'
Write-Output "Maquina: $($settings.MachineId)"
Write-Output "DevDocs: $($settings.DocsRoot)"
Write-Output "farmia_app: $($settings.FarmiaRepo)"
Write-Output "Worktrees: $($settings.WorktreesRoot)"
Write-Output "Config local presente: $($settings.ConfigExists)"

Write-DiagnosticSection 'Git'
$branchName = $null
if (-not (Test-Path -LiteralPath $settings.FarmiaRepo -PathType Container)) {
  Write-Output 'No se encontro farmia_app.'
} else {
  Invoke-GitReadOnly @('status', '--short', '--branch')
  $branch = Invoke-GitReadOnly @('branch', '--show-current')
  $branchName = $branch -join ''
  Write-Output "Rama: $branchName"
  $upstream = Invoke-GitReadOnly @('rev-parse', '--abbrev-ref', '--symbolic-full-name', '@{upstream}')
  Write-Output "Tracking: $($upstream -join '')"
  if (($upstream -join '') -notlike 'No disponible:*') {
    $divergence = Invoke-GitReadOnly @('rev-list', '--left-right', '--count', 'HEAD...@{upstream}')
    Write-Output "Divergencia (local/remoto): $($divergence -join '')"
  }
  Write-Output 'Stashes (referencia, fecha, asunto):'
  $stashes = @(Invoke-GitReadOnly @('stash', 'list', '--format=%gd %cs %s'))
  if ($stashes.Count -eq 0 -or -not ($stashes -join '').Trim()) { Write-Output '  ninguno' }
  else { $stashes | ForEach-Object { Write-Output "  $_" } }
}

$manifestPath = Join-Path $settings.FarmiaRepo '.farmia-worktree.local.json'
$manifest = $null
Write-DiagnosticSection 'Manifest local no sensible'
if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
  try {
    $rawManifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding utf8 | ConvertFrom-Json
    $manifest = [PSCustomObject]@{
      version = $rawManifest.version
      branch = $rawManifest.branch
      slug = $rawManifest.slug
      slot = $rawManifest.slot
      composeProject = $rawManifest.composeProject
      databaseName = $rawManifest.databaseName
      ports = $rawManifest.ports
      volumes = $rawManifest.volumes
    }
    $manifest | ConvertTo-Json -Depth 4
    if ($branchName -and $manifest.branch -ne $branchName) {
      Write-Output "ADVERTENCIA: el manifest corresponde a '$($manifest.branch)' y la rama actual es '$branchName'."
    }
  } catch { Write-Output "Manifest invalido: $($_.Exception.Message)" }
} else { Write-Output "No existe: $manifestPath" }

Write-DiagnosticSection 'Docker Compose y contenedores'
if (Get-Command docker -ErrorAction SilentlyContinue) {
  $compose = & docker compose ls --format json 2>&1
  if ($LASTEXITCODE -eq 0) { $compose } else { Write-Output "Compose no disponible: $($compose -join ' ')" }
  $containers = & docker ps --format '{{.Names}} | {{.Status}} | {{.Ports}} | {{.Label "com.docker.compose.project"}}' 2>&1
  if ($LASTEXITCODE -eq 0) { $containers } else { Write-Output "Docker ps no disponible: $($containers -join ' ')" }
} else { Write-Output 'Docker no esta en PATH.' }

Write-DiagnosticSection 'Puertos y health checks'
if ($manifest) {
  $portValues = @($manifest.ports.psobject.Properties | ForEach-Object { [int]$_.Value })
  try {
    $listeners = @(Get-NetTCPConnection -State Listen -ErrorAction Stop | Where-Object { $portValues -contains $_.LocalPort })
    if ($listeners.Count -eq 0) { Write-Output 'Ningun puerto del manifest esta escuchando.' }
    else { $listeners | Select-Object LocalAddress, LocalPort, OwningProcess | Format-Table -AutoSize | Out-String | Write-Output }
  } catch { Write-Output "No se pudieron consultar listeners: $($_.Exception.Message)" }

  @(
    Test-HttpEndpoint 'API' "http://127.0.0.1:$($manifest.ports.api)/health"
    Test-HttpEndpoint 'Worker' "http://127.0.0.1:$($manifest.ports.worker)/health"
    Test-HttpEndpoint 'LocalStack' "http://127.0.0.1:$($manifest.ports.localstack)/_localstack/health"
    Test-HttpEndpoint 'Frontend runtime' "http://127.0.0.1:$($manifest.ports.frontend)/__farmia/runtime"
    Test-HttpEndpoint 'Frontend proxy' "http://127.0.0.1:$($manifest.ports.frontend)/api/health/live"
  ) | Format-Table -AutoSize | Out-String | Write-Output
} else { Write-Output 'Sin manifest: no se infieren puertos ni endpoints.' }
