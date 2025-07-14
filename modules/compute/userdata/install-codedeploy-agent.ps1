<powershell>
param (
  [string]$Region = "${region}",   
  [string]$Temp   = "C:\Temp"
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

New-Item -ItemType Directory -Path $Temp -Force | Out-Null
Start-Transcript -Path "$Temp\user-data.log" -Append

Write-Host "[Init] Starting CodeDeploy Agent installation"
Write-Host "[Init] Region: $Region"
Write-Host "[Init] Temp directory: $Temp"
Write-Host "[Init] Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

function Install-MSI {
    param(
        [string]$File,   
        [string[]]$Urls     
    )
    Write-Host "[Download] Attempting to download MSI package"
    foreach ($u in $Urls) {
        Write-Host "[Download] Trying URL: $u"
        try {
            Invoke-WebRequest $u -OutFile $File -UseBasicParsing -TimeoutSec 60
            if ((Get-Item $File).Length -gt 1MB) { 
                Write-Host "[Download] Success - File size: $((Get-Item $File).Length) bytes"
                break 
            } else {
                Write-Host "[Download] Failed - File too small"
            }
        } catch { 
            Write-Host "[Download] Failed - Error: $_"
            Remove-Item $File -ErrorAction SilentlyContinue 
        }
    }
    if (-not (Test-Path $File)) { 
        Write-Host "[Download] Critical - All download attempts failed"
        throw "Download failed: $($Urls -join ', ')" 
    }
    
    Write-Host "[Install] Starting MSI installation"
    msiexec /i $File /qn /norestart /l*v "$Temp\codedeploy.log"
    Write-Host "[Install] MSI installation command executed"
}

# ---------- CodeDeploy Agent ----------
Write-Host "[Setup] Configuring CodeDeploy Agent installation"
$cdFile = "$Temp\codedeploy.msi"
$cdUrls = @(
  "https://aws-codedeploy-$Region.s3.$Region.amazonaws.com/latest/codedeploy-agent.msi",
  "https://s3.$Region.amazonaws.com/aws-codedeploy-$Region/latest/codedeploy-agent.msi"
)

Write-Host "[Setup] Target file: $cdFile"
Write-Host "[Setup] Available URLs: $($cdUrls.Count)"

Install-MSI $cdFile $cdUrls

Write-Host "[Service] Configuring CodeDeploy Agent service"
Set-Service codedeployagent -StartupType Automatic
Write-Host "[Service] Service startup type set to Automatic"

Write-Host "[Service] Starting CodeDeploy Agent service"
Start-Service codedeployagent
Write-Host "[Service] Service start command executed"

Write-Host "[Complete] CodeDeploy Agent installation finished"
Write-Host "[Complete] Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

Stop-Transcript
</powershell>
