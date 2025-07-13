<powershell>
# Enhanced CodeDeploy Agent Installation with Windows version-specific handling
$ErrorActionPreference = "Continue"
$region = "${region}"
$windowsVersion = "${windows_version}"  # Pass from Terraform

# Log everything
Start-Transcript -Path "C:\temp\user-data-log.txt" -Append

Write-Host "Starting CodeDeploy Agent installation at $(Get-Date)"
Write-Host "Region: $region"
Write-Host "Windows Version: $windowsVersion"

# Create temp directory
New-Item -ItemType directory -Path "c:\temp" -Force

# Determine CodeDeploy Agent version based on Windows version
$agentVersion = "latest"
$downloadUrl = ""

switch ($windowsVersion) {
    "2016" {
        # Windows Server 2016 - Use last supported version 1.5.0
        $agentVersion = "1.5.0"
        $downloadUrl = "https://aws-codedeploy-$region.s3.$region.amazonaws.com/releases/codedeploy-agent-1.5.0.msi"
        Write-Host "Using CodeDeploy Agent v1.5.0 (last supported for Windows 2016)"
    }
    "2019" {
        # Windows Server 2019 - Can use latest
        $agentVersion = "latest"
        $downloadUrl = "https://aws-codedeploy-$region.s3.$region.amazonaws.com/latest/codedeploy-agent.msi"
        Write-Host "Using latest CodeDeploy Agent for Windows 2019"
    }
    "2022" {
        # Windows Server 2022 - Can use latest
        $agentVersion = "latest"
        $downloadUrl = "https://aws-codedeploy-$region.s3.$region.amazonaws.com/latest/codedeploy-agent.msi"
        Write-Host "Using latest CodeDeploy Agent for Windows 2022"
    }
    default {
        # Default to latest for unknown versions
        $agentVersion = "latest"
        $downloadUrl = "https://aws-codedeploy-$region.s3.$region.amazonaws.com/latest/codedeploy-agent.msi"
        Write-Host "Using latest CodeDeploy Agent (default)"
    }
}

Write-Host "Download URL: $downloadUrl"

# Stop existing CodeDeploy agent if running
try {
    $existingService = Get-Service -Name codedeployagent -ErrorAction SilentlyContinue
    if ($existingService) {
        Write-Host "Found existing CodeDeploy agent service: $($existingService.Status)"
        if ($existingService.Status -eq "Running") {
            Stop-Service -Name codedeployagent -Force -ErrorAction SilentlyContinue
            Write-Host "Stopped existing CodeDeploy agent"
        }
    } else {
        Write-Host "No existing CodeDeploy agent service found"
    }
} catch {
    Write-Host "Error checking existing service: $_"
}

# Download and install CodeDeploy Agent
try {
    Write-Host "Downloading CodeDeploy Agent version $agentVersion..."
    
    # Use TLS 1.2 for download
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    # Download with retry logic
    $maxRetries = 3
    $retryCount = 0
    $downloadSuccess = $false
    
    while ($retryCount -lt $maxRetries -and -not $downloadSuccess) {
        try {
            $retryCount++
            Write-Host "Download attempt $retryCount of $maxRetries..."
            
            Invoke-WebRequest -Uri $downloadUrl -OutFile "c:\temp\codedeploy-agent.msi" -UseBasicParsing
            
            # Verify download
            if (Test-Path "c:\temp\codedeploy-agent.msi") {
                $fileSize = (Get-Item "c:\temp\codedeploy-agent.msi").Length
                Write-Host "Downloaded successfully. File size: $fileSize bytes"
                $downloadSuccess = $true
            } else {
                throw "Downloaded file not found"
            }
        } catch {
            Write-Host "Download attempt $retryCount failed: $_"
            if ($retryCount -lt $maxRetries) {
                Write-Host "Retrying in 10 seconds..."
                Start-Sleep -Seconds 10
            }
        }
    }
    
    if (-not $downloadSuccess) {
        throw "Failed to download CodeDeploy Agent after $maxRetries attempts"
    }
    
    Write-Host "Installing CodeDeploy Agent..."
    
    # Uninstall existing version first
    try {
        $app = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*CodeDeploy*" }
        if ($app) {
            Write-Host "Uninstalling existing CodeDeploy agent: $($app.Name) v$($app.Version)"
            $app.Uninstall()
            Start-Sleep -Seconds 15
            Write-Host "Existing agent uninstalled"
        } else {
            Write-Host "No existing CodeDeploy agent found to uninstall"
        }
    } catch {
        Write-Host "Warning: Could not uninstall existing agent: $_"
    }
    
    # Install new version
    Write-Host "Installing CodeDeploy Agent version $agentVersion..."
    $installArgs = @("/quiet", "/l*v", "c:\temp\host-agent-install-log.txt")
    
    $installProcess = Start-Process -FilePath "c:\temp\codedeploy-agent.msi" -ArgumentList $installArgs -Wait -PassThru
    
    Write-Host "Installation process exit code: $($installProcess.ExitCode)"
    
    if ($installProcess.ExitCode -eq 0) {
        Write-Host "Installation completed successfully"
    } else {
        Write-Host "Installation completed with exit code: $($installProcess.ExitCode)"
    }
    
    Start-Sleep -Seconds 20
    
    Write-Host "Configuring CodeDeploy Agent Service..."
    
    # Configure service
    try {
        Set-Service -Name codedeployagent -StartupType Automatic -ErrorAction Stop
        Write-Host "Service startup type set to Automatic"
    } catch {
        Write-Host "Warning: Could not set service startup type: $_"
    }
    
    # Start service with retry
    $maxStartRetries = 3
    $startRetryCount = 0
    $serviceStarted = $false
    
    while ($startRetryCount -lt $maxStartRetries -and -not $serviceStarted) {
        try {
            $startRetryCount++
            Write-Host "Starting service attempt $startRetryCount of $maxStartRetries..."
            
            Start-Service -Name codedeployagent -ErrorAction Stop
            Start-Sleep -Seconds 5
            
            $service = Get-Service -Name codedeployagent -ErrorAction Stop
            if ($service.Status -eq "Running") {
                Write-Host "Service started successfully"
                $serviceStarted = $true
            } else {
                throw "Service status is $($service.Status)"
            }
        } catch {
            Write-Host "Start attempt $startRetryCount failed: $_"
            if ($startRetryCount -lt $maxStartRetries) {
                Write-Host "Retrying in 10 seconds..."
                Start-Sleep -Seconds 10
            }
        }
    }
    
    # Verify installation
    try {
        $service = Get-Service -Name codedeployagent -ErrorAction SilentlyContinue
        if ($service) {
            Write-Host "CodeDeploy Agent service found. Status: $($service.Status)"
            
            # Check agent version if possible
            $agentLogPath = "C:\ProgramData\Amazon\CodeDeploy\log\codedeploy-agent.log"
            if (Test-Path $agentLogPath) {
                Write-Host "Agent log file exists: $agentLogPath"
            }
            
            if ($service.Status -eq "Running") {
                Write-Host "SUCCESS: CodeDeploy Agent installation completed and service is running"
            } else {
                Write-Host "WARNING: CodeDeploy Agent installed but service is not running"
            }
        } else {
            Write-Host "ERROR: CodeDeploy Agent service not found after installation"
        }
    } catch {
        Write-Host "Error verifying installation: $_"
    }
    
} catch {
    Write-Host "CRITICAL ERROR during CodeDeploy Agent installation: $_"
    Write-Host "Stack trace: $($_.ScriptStackTrace)"
}

# Configure Windows for automation
try {
    Write-Host "Configuring Windows execution policy..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force -ErrorAction SilentlyContinue
    Write-Host "Execution policy set to RemoteSigned"
} catch {
    Write-Host "Could not set execution policy: $_"
}

# Enable RDP for debugging (optional)
try {
    Write-Host "Enabling RDP for debugging..."
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0 -ErrorAction SilentlyContinue
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue
    Write-Host "RDP enabled"
} catch {
    Write-Host "Could not enable RDP: $_"
}

# Final comprehensive status check
Write-Host "=== FINAL STATUS CHECK ==="
try {
    # Service status
    $finalService = Get-Service -Name codedeployagent -ErrorAction SilentlyContinue
    if ($finalService) {
        Write-Host "Service Status: $($finalService.Status)"
        Write-Host "Service StartType: $($finalService.StartType)"
    } else {
        Write-Host "ERROR: Service not found"
    }
    
    # Check if agent files exist
    $agentPath = "C:\opt\codedeploy-agent"
    if (Test-Path $agentPath) {
        Write-Host "Agent files found at: $agentPath"
    } else {
        Write-Host "WARNING: Agent files not found at expected location"
    }
    
    # Log file status
    $logPath = "C:\ProgramData\Amazon\CodeDeploy\log"
    if (Test-Path $logPath) {
        Write-Host "Log directory exists: $logPath"
        $logFiles = Get-ChildItem $logPath -ErrorAction SilentlyContinue
        Write-Host "Log files found: $($logFiles.Count)"
    }
    
    # Final verdict
    if ($finalService -and $finalService.Status -eq "Running") {
        Write-Host "✅ SUCCESS: CodeDeploy Agent v$agentVersion is properly installed and running"
    } else {
        Write-Host "❌ FAILURE: CodeDeploy Agent installation or startup failed"
    }
    
} catch {
    Write-Host "Error in final status check: $_"
}

Write-Host "EC2 instance initialization completed at $(Get-Date)"
Write-Host "Windows Version: $windowsVersion, Agent Version: $agentVersion"

Stop-Transcript
</powershell>