<powershell>
# Enhanced CodeDeploy Agent Installation with force reinstall
$ErrorActionPreference = "Continue"
$region = "${region}"

# Log everything
Start-Transcript -Path "C:\temp\user-data-log.txt" -Append

Write-Host "Starting CodeDeploy Agent installation at $(Get-Date)"
Write-Host "Region: $region"

# Create temp directory
New-Item -ItemType directory -Path "c:\temp" -Force

# Stop existing CodeDeploy agent if running
try {
    Stop-Service -Name codedeployagent -Force -ErrorAction SilentlyContinue
    Write-Host "Stopped existing CodeDeploy agent"
} catch {
    Write-Host "No existing CodeDeploy agent to stop"
}

# Download and install CodeDeploy Agent
try {
    Write-Host "Downloading CodeDeploy Agent..."
    $url = "https://aws-codedeploy-$region.s3.$region.amazonaws.com/latest/codedeploy-agent.msi"
    Invoke-WebRequest -Uri $url -OutFile "c:\temp\codedeploy-agent.msi"
    
    Write-Host "Installing CodeDeploy Agent (force reinstall)..."
    # Uninstall existing version first
    $app = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*CodeDeploy*" }
    if ($app) {
        Write-Host "Uninstalling existing CodeDeploy agent..."
        $app.Uninstall()
        Start-Sleep -Seconds 10
    }
    
    # Install new version
    Start-Process -FilePath "c:\temp\codedeploy-agent.msi" -ArgumentList "/quiet", "/l*v", "c:\temp\host-agent-install-log.txt" -Wait
    Start-Sleep -Seconds 15
    
    Write-Host "Configuring CodeDeploy Agent Service..."
    Set-Service -Name codedeployagent -StartupType Automatic -ErrorAction SilentlyContinue
    Start-Service -Name codedeployagent -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    
    # Verify installation
    $service = Get-Service -Name codedeployagent -ErrorAction SilentlyContinue
    if ($service) {
        Write-Host "CodeDeploy Agent service status: $($service.Status)"
        if ($service.Status -eq "Running") {
            Write-Host "CodeDeploy Agent installation completed successfully"
        } else {
            Write-Host "CodeDeploy Agent installed but not running, attempting to start..."
            Start-Service -Name codedeployagent -Force
        }
    } else {
        Write-Host "CodeDeploy Agent service not found after installation"
    }
    
} catch {
    Write-Host "Error during CodeDeploy Agent installation: $_"
}

# Configure Windows for automation
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force -ErrorAction SilentlyContinue
    Write-Host "Execution policy set to RemoteSigned"
} catch {
    Write-Host "Could not set execution policy: $_"
}

# Enable RDP for debugging
try {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0 -ErrorAction SilentlyContinue
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue
    Write-Host "RDP enabled for debugging"
} catch {
    Write-Host "Could not enable RDP: $_"
}

# Final status check
try {
    $finalService = Get-Service -Name codedeployagent -ErrorAction SilentlyContinue
    if ($finalService -and $finalService.Status -eq "Running") {
        Write-Host "SUCCESS: CodeDeploy Agent is running"
    } else {
        Write-Host "WARNING: CodeDeploy Agent is not running"
    }
} catch {
    Write-Host "Could not check final service status"
}

Write-Host "EC2 instance initialization completed at $(Get-Date)"
Stop-Transcript
</powershell>
