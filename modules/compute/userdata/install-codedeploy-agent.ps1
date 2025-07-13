<powershell>
$ErrorActionPreference = "Continue"
$region = "${region}"
$windowsVersion = "${windows_version}"

New-Item -ItemType Directory -Path "C:\temp" -Force | Out-Null
Start-Transcript -Path "C:\temp\user-data.log" -Append

Write-Host "=== SETUP START ($windowsVersion/$region) $(Get-Date) ==="

function Download-WithRetry {
    param($Url, $OutputPath, $MaxRetries = 3)
    for ($i = 1; $i -le $MaxRetries; $i++) {
        try {
            Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing -TimeoutSec 60
            if ((Test-Path $OutputPath) -and ((Get-Item $OutputPath).Length -gt 500KB)) {
                return $true
            }
            throw "Size check failed"
        } catch {
            Remove-Item $OutputPath -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        }
    }
    return $false
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Install CodeDeploy Agent
Write-Host "Installing CodeDeploy..."
$codeDeployUrls = @(
    "https://aws-codedeploy-$region.s3.$region.amazonaws.com/latest/codedeploy-agent.msi",
    "https://s3.$region.amazonaws.com/aws-codedeploy-$region/latest/codedeploy-agent.msi"
)

$downloaded = $false
foreach ($u in $codeDeployUrls) {
    if (Download-WithRetry -Url $u -OutputPath "C:\temp\cd-agent.msi") {
        $downloaded = $true
        break
    }
}
if (-not $downloaded) { 
    Write-Host "!!! CodeDeploy download failed"
    exit 1 
}

$service = Get-Service codedeployagent -ErrorAction SilentlyContinue
if ($service -and $service.Status -eq 'Running') { 
    Stop-Service $service.Name -Force 
}

# Create CORRECT CodeDeploy log directories per AWS Documentation
New-Item -ItemType Directory -Path "C:\ProgramData\Amazon\CodeDeploy\log" -Force | Out-Null
New-Item -ItemType Directory -Path "C:\ProgramData\Amazon\CodeDeploy\deployment-logs" -Force | Out-Null

$proc = Start-Process -FilePath "C:\temp\cd-agent.msi" -ArgumentList "/quiet" -Wait -Passthru
Start-Sleep -Seconds 15

Set-Service codedeployagent -StartupType Automatic
Start-Service codedeployagent
Start-Sleep -Seconds 10

# Install CloudWatch Agent
Write-Host "Installing CloudWatch..."
$cwUrl = "https://amazoncloudwatch-agent-$region.s3.$region.amazonaws.com/windows/amd64/latest/amazon-cloudwatch-agent.msi"
if (-not (Download-WithRetry -Url $cwUrl -OutputPath "C:\temp\cw-agent.msi")) {
    Write-Host "!!! CloudWatch download failed"
    exit 1
}

$proc = Start-Process -FilePath "C:\temp\cw-agent.msi" -ArgumentList "/quiet" -Wait -Passthru
Start-Sleep -Seconds 15

# CloudWatch Config - FIXED để khớp với AWS Documentation
$configDir = "C:\ProgramData\Amazon\AmazonCloudWatchAgent"
$configPath = "$configDir\amazon-cloudwatch-agent.json"
New-Item -ItemType Directory -Path $configDir -Force | Out-Null

$config = @{
    agent = @{ 
        metrics_collection_interval = 60
        region = $region
    }
    logs = @{
        logs_collected = @{
            files = @{
                collect_list = @(
                    @{
                        file_path = "C:\\ProgramData\\Amazon\\CodeDeploy\\log\\codedeploy-agent-log.txt"
                        log_group_name = "/aws/codedeploy/agent"
                        log_stream_name = "{instance_id}-agent"
                        timezone = "UTC"
                    },
                    @{
                        file_path = "C:\\ProgramData\\Amazon\\CodeDeploy\\deployment-logs\\codedeploy-agent-deployments.log"
                        log_group_name = "/aws/codedeploy/deployments"
                        log_stream_name = "{instance_id}-deployments"
                        timezone = "UTC"
                    },
                    @{
                        file_path = "C:\\ProgramData\\Amazon\\CodeDeploy\\*\\*\\logs\\scripts.log"
                        log_group_name = "/aws/codedeploy/scripts"
                        log_stream_name = "{instance_id}-scripts"
                        timezone = "UTC"
                    },
                    @{
                        file_path = "C:\\temp\\user-data.log"
                        log_group_name = "/aws/ec2/userdata"
                        log_stream_name = "{instance_id}-userdata"
                        timezone = "UTC"
                    }
                )
            }
            windows_events = @{
                collect_list = @(
                    @{
                        event_name = "System"
                        event_levels = @("ERROR", "WARNING")
                        log_group_name = "/aws/ec2/windows/system"
                        log_stream_name = "{instance_id}-system"
                    },
                    @{
                        event_name = "Application"
                        event_levels = @("ERROR", "WARNING")
                        log_group_name = "/aws/ec2/windows/application"
                        log_stream_name = "{instance_id}-application"
                    }
                )
            }
        }
    }
    metrics = @{
        namespace = "CWAgent"
        metrics_collected = @{
            Memory = @{
                measurement = @("% Committed Bytes In Use")
                metrics_collection_interval = 60
            }
            Processor = @{
                measurement = @("% Idle Time", "% User Time")
                metrics_collection_interval = 60
                resources = @("*")
            }
            LogicalDisk = @{
                measurement = @("% Free Space")
                metrics_collection_interval = 60
                resources = @("*")
            }
        }
    }
}

$config | ConvertTo-Json -Depth 10 | Out-File -FilePath $configPath -Encoding UTF8

Write-Host "Starting CloudWatch Agent..."
try {
    # Stop agent first
    & "C:\Program Files\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent-ctl.ps1" -a stop
    Start-Sleep -Seconds 5
    
    # Apply new config
    & "C:\Program Files\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent-ctl.ps1" -a fetch-config -m ec2 -s -c file:$configPath
    Start-Sleep -Seconds 15
    
    # Check status
    $status = & "C:\Program Files\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent-ctl.ps1" -a status
    Write-Host "CloudWatch Agent Status: $status"
    
} catch {
    Write-Host "Error with CloudWatch Agent: $_"
}

# Create test log entries với ĐÚNG file names theo AWS Documentation
Write-Host "Creating test log entries..."
"$(Get-Date) - CodeDeploy Agent initialized - Test entry from user-data" | Out-File -FilePath "C:\ProgramData\Amazon\CodeDeploy\log\codedeploy-agent-log.txt" -Append -Encoding UTF8
"$(Get-Date) - Deployment logs initialized - Test entry" | Out-File -FilePath "C:\ProgramData\Amazon\CodeDeploy\deployment-logs\codedeploy-agent-deployments.log" -Append -Encoding UTF8

# Ensure log permissions
Write-Host "Setting log file permissions..."
try {
    $dirs = @(
        "C:\ProgramData\Amazon\CodeDeploy\log",
        "C:\ProgramData\Amazon\CodeDeploy\deployment-logs"
    )
    
    foreach ($dir in $dirs) {
        $acl = Get-Acl $dir
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","FullControl","ContainerInherit,ObjectInherit","None","Allow")
        $acl.SetAccessRule($accessRule)
        Set-Acl $dir $acl
    }
    Write-Host "Log permissions updated"
} catch {
    Write-Host "Could not update log permissions: $_"
}

# Windows Config
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
try {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
} catch { 
    Write-Host "RDP config failed"
}

# Enhanced Status Check
Write-Host "=== STATUS ==="
$services = @('codedeployagent','AmazonCloudWatchAgent')
foreach ($svc in $services) {
    $s = Get-Service $svc -ErrorAction SilentlyContinue
    if ($s) { 
        Write-Host "$svc : $($s.Status)" 
    }
}

# Check CORRECT log paths per AWS Documentation
Write-Host "=== LOG FILE VERIFICATION ==="
$expectedFiles = @(
    "C:\ProgramData\Amazon\CodeDeploy\log\codedeploy-agent-log.txt",
    "C:\ProgramData\Amazon\CodeDeploy\deployment-logs\codedeploy-agent-deployments.log"
)

foreach ($filePath in $expectedFiles) {
    if (Test-Path $filePath) {
        $size = (Get-Item $filePath).Length
        Write-Host "✅ File exists: $filePath ($size bytes)"
    } else {
        Write-Host "❌ File missing: $filePath"
    }
}

# Check all directories recursively
$logPaths = @(
    "C:\ProgramData\Amazon\CodeDeploy\log",
    "C:\ProgramData\Amazon\CodeDeploy\deployment-logs",
    "C:\ProgramData\Amazon\CodeDeploy"
)

foreach ($path in $logPaths) {
    if (Test-Path $path) {
        Write-Host "✅ Directory exists: $path"
        $files = Get-ChildItem $path -File -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            Write-Host "   📁 $($file.FullName) ($($file.Length) bytes)"
        }
    } else {
        Write-Host "❌ Directory missing: $path"
    }
}

# Check CloudWatch Agent detailed logs
Write-Host "=== CLOUDWATCH AGENT DETAILED CHECK ==="
$cwLogPaths = @(
    "C:\ProgramData\Amazon\AmazonCloudWatchAgent\Logs\amazon-cloudwatch-agent.log",
    "C:\ProgramData\Amazon\AmazonCloudWatchAgent\Logs\configuration-validation.log"
)

foreach ($logPath in $cwLogPaths) {
    if (Test-Path $logPath) {
        Write-Host "=== $logPath (last 5 lines) ==="
        Get-Content $logPath -Tail 5 | ForEach-Object { Write-Host "  $_" }
    }
}

Write-Host "=== SETUP COMPLETE $(Get-Date) ==="
Stop-Transcript
</powershell>