<powershell>
# Compact CodeDeploy Agent Installation
$ErrorActionPreference = "Continue"
$region = "${region}"
$windowsVersion = "${windows_version}"

# Create temp directory and start logging
New-Item -ItemType directory -Path "c:\temp" -Force
Start-Transcript -Path "C:\temp\user-data-log.txt" -Append

Write-Host "Installing CodeDeploy Agent for Windows $windowsVersion in region $region at $(Get-Date)"

# Determine download URLs based on Windows version
$downloadUrls = @()
switch ($windowsVersion) {
    "2016" {
        $downloadUrls = @(
            "https://s3.$region.amazonaws.com/aws-codedeploy-$region/latest/codedeploy-agent.msi",
            "https://aws-codedeploy-$region.s3.$region.amazonaws.com/latest/codedeploy-agent.msi"
        )
    }
    default {
        $downloadUrls = @(
            "https://s3.$region.amazonaws.com/aws-codedeploy-$region/latest/codedeploy-agent.msi"
        )
    }
}

# Stop existing service
try {
    $service = Get-Service -Name codedeployagent -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq "Running") {
        Stop-Service -Name codedeployagent -Force
        Write-Host "Stopped existing service"
    }
} catch { Write-Host "No existing service to stop" }

# Download with fallback
$downloadSuccess = $false
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

foreach ($url in $downloadUrls) {
    if ($downloadSuccess) { break }
    try {
        Write-Host "Downloading from: $url"
        Invoke-WebRequest -Uri $url -OutFile "c:\temp\codedeploy-agent.msi" -UseBasicParsing -TimeoutSec 60
        
        if (Test-Path "c:\temp\codedeploy-agent.msi") {
            $size = (Get-Item "c:\temp\codedeploy-agent.msi").Length
            if ($size -gt 1000000) {
                Write-Host "Download successful: $size bytes"
                $downloadSuccess = $true
            }
        }
    } catch {
        Write-Host "Download failed: $_"
        if (Test-Path "c:\temp\codedeploy-agent.msi") {
            Remove-Item "c:\temp\codedeploy-agent.msi" -Force -ErrorAction SilentlyContinue
        }
    }
}

if (-not $downloadSuccess) {
    Write-Host "ERROR: All download attempts failed"
    Stop-Transcript
    exit 1
}

# Uninstall existing
try {
    $app = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*CodeDeploy*" }
    if ($app) {
        Write-Host "Uninstalling existing: $($app.Name)"
        $app.Uninstall()
        Start-Sleep -Seconds 10
    }
} catch { Write-Host "No existing installation to remove" }

# Install
Write-Host "Installing CodeDeploy Agent..."
$process = Start-Process -FilePath "c:\temp\codedeploy-agent.msi" -ArgumentList "/quiet", "/l*v", "c:\temp\install.log" -Wait -PassThru
Write-Host "Installation exit code: $($process.ExitCode)"

Start-Sleep -Seconds 15

# Configure and start service
try {
    Set-Service -Name codedeployagent -StartupType Automatic
    Start-Service -Name codedeployagent
    Start-Sleep -Seconds 5
    
    $finalService = Get-Service -Name codedeployagent
    Write-Host "Service status: $($finalService.Status)"
    
    if ($finalService.Status -eq "Running") {
        Write-Host "SUCCESS: CodeDeploy Agent installed and running"
    } else {
        Write-Host "WARNING: Service not running"
    }
} catch {
    Write-Host "ERROR configuring service: $_"
}

# Configure Windows
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force -ErrorAction SilentlyContinue

# Enable RDP
try {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue
    Write-Host "RDP enabled"
} catch { Write-Host "RDP setup failed" }

Write-Host "Installation completed at $(Get-Date)"
Stop-Transcript
</powershell>