$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

$ZipName = "AI-Video-App-lightweight.zip"
$ZipPath = Join-Path $Root $ZipName
$Stage = Join-Path $env:TEMP ("ai_video_app_lightweight_" + [guid]::NewGuid().ToString("N"))

$ExcludeTopDirs = @("models", "venv")
$ExcludeDirNames = @("node_modules", "__pycache__", ".git", ".pytest_cache", "projects", "uploads", "voice_previews")
$ExcludeFileNames = @("models.zip", $ZipName, "backend.log", "frontend.log", "frontend-dev.log")

function Copy-TreeExcluding {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    New-Item -ItemType Directory -Path $Destination -Force | Out-Null

    Get-ChildItem -LiteralPath $Source -Force | ForEach-Object {
        if ($_.PSIsContainer) {
            if ($ExcludeDirNames -contains $_.Name) {
                return
            }

            Copy-TreeExcluding -Source $_.FullName -Destination (Join-Path $Destination $_.Name)
            return
        }

        if ($ExcludeFileNames -contains $_.Name) {
            return
        }

        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $Destination $_.Name) -Force
    }
}

try {
    if (Test-Path $ZipPath) {
        Remove-Item -LiteralPath $ZipPath -Force
    }

    New-Item -ItemType Directory -Path $Stage -Force | Out-Null

    Get-ChildItem -LiteralPath $Root -Force | ForEach-Object {
        if ($_.PSIsContainer) {
            if ($ExcludeTopDirs -contains $_.Name -or $ExcludeDirNames -contains $_.Name) {
                return
            }

            Copy-TreeExcluding -Source $_.FullName -Destination (Join-Path $Stage $_.Name)
            return
        }

        if ($ExcludeFileNames -contains $_.Name) {
            return
        }

        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $Stage $_.Name) -Force
    }

    if (Test-Path (Join-Path $Stage "models")) {
        throw "Package validation failed: models folder was included."
    }
    if (Test-Path (Join-Path $Stage "models.zip")) {
        throw "Package validation failed: models.zip was included."
    }

    $Items = Get-ChildItem -LiteralPath $Stage -Force
    if (-not $Items) {
        throw "Package validation failed: no files were staged."
    }

    Compress-Archive -Path $Items.FullName -DestinationPath $ZipPath -Force
    $ZipSizeMb = [math]::Round((Get-Item $ZipPath).Length / 1MB, 2)

    Write-Host "Created $ZipName ($ZipSizeMb MB)"
    Write-Host "Models are excluded. Use DOWNLOAD_MODEL=true on the target machine only if AI images are required."
}
finally {
    if (Test-Path $Stage) {
        Remove-Item -LiteralPath $Stage -Recurse -Force -ErrorAction SilentlyContinue
    }
}