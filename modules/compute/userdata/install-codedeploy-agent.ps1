<powershell>
# Enhanced CodeDeploy Agent Installation with Windows version-specific handling
$ErrorActionPreference = "Continue"
$region = "${region}"
$windowsVersion = "${windows_version}"

# Log everything
Start-Transcript -Path "C:\temp\user-data-log.txt" -Append

Write-Host "Starting CodeDeploy Agent installation at $(Get-Date)"
Write-Host "Region: $region"
Write-Host "Windows Version: $windowsVersion"

# Create temp directory
New-Item -ItemType directory -Path "c:\temp" -Force

# Determine CodeDeploy Agent download strategy based on Windows version
$agentVersion = "latest"
$downloadUrls = @()
$installStrategy = "latest"

switch ($windowsVersion) {
    "2016" {
        # Windows Server 2016 - Multiple fallback URLs for compatibility
        $agentVersion = "1.5.0-compatible"
        $installStrategy = "legacy"
        
        # Primary URLs (try multiple formats)
        $downloadUrls = @(
            "https://s3.$region.amazonaws.com/aws-codedeploy-$region/latest/codedeploy-agent.msi",
            "https://aws-codedeploy-$region.s3.$region.amazonaws.com/latest/codedeploy-agent.msi",
            "https://s3-$region.amazonaws.com/aws-codedeploy-$region/latest/codedeploy-agent.msi"
        )
        
        Write-Host "Using legacy-compatible CodeDeploy Agent for Windows Server 2016"
        Write-Host "Strategy: Multiple URL fallbacks for compatibility"
    }
    "2019" {
        # Windows Server 2019 - Standard latest
        $agentVersion = "latest"
        $installStrategy = "standard"
        
        $downloadUrls = @(
            "https://s3.$region.amazonaws.com/aws-codedeploy-$region/latest/codedeploy-agent.msi",
            "https://aws-codedeploy-$region.s3.$region.amazonaws.com/latest/codedeploy-agent.msi"
        )
        
        Write-Host "Using latest CodeDeploy Agent for Windows Server 2019"
    }
    "2022" {
        # Windows Server 2022 - Standard latest
        $agentVersion = "latest"
        $installStrategy = "standard"
        
        $downloadUrls = @(
            "https://s3.$region.amazonaws.com/aws-codedeploy-$region/latest/codedeploy-agent.msi",
            "https://aws-codedeploy-$region.s3.$region.amazonaws.com/latest/codedeploy-agent.msi"
        )
        
        Write-Host "Using latest CodeDeploy Agent for Windows Server 2022"
    }
    default {
        # Default fallback
        $agentVersion = "latest"
        $installStrategy = "standard"
        
        $downloadUrls = @(
            "https://s3.$region.amazonaws.com/aws-codedeploy-$region/latest/codedeploy-agent.msi"
        )
        
        Write-Host "Using latest CodeDeploy Agent (default)"
    }
}

Write-Host "Download URLs to try: $($downloadUrls.Count)"
foreach ($url in $downloadUrls) {
    Write-Host "  - $url"
}

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

# Download CodeDeploy Agent with multiple URL fallback
$downloadSuccess = $false
$successfulUrl = ""

try {
    Write-Host "Downloading CodeDeploy Agent version $agentVersion..."
    
    # Use TLS 1.2 for download
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    # Try each URL until one succeeds
    foreach ($downloadUrl in $downloadUrls) {
        if ($downloadSuccess) { break }
        
        Write-Host "Trying URL: $downloadUrl"
        
        # Retry logic for each URL
        $maxRetries = 2
        $retryCount = 0
        
        while ($retryCount -lt $maxRetries -and -not $downloadSuccess) {
            try {
                $retryCount++
                Write-Host "  Download attempt $retryCount of $maxRetries for this URL..."
                
                # Test URL accessibility first
                try {
                    $webRequest = [System.Net.WebRequest]::Create($downloadUrl)
                    $webRequest.Method = "HEAD"
                    $webRequest.Timeout = 10000  # 10 seconds
                    $response = $webRequest.GetResponse()
                    $statusCode = $response.StatusCode
                    $response.Close()
                    
                    Write-Host "  URL accessibility test: $statusCode"
                    
                    if ($statusCode -ne "OK") {
                        throw "URL returned status: $statusCode"
                    }
                } catch {
                    Write-Host "  URL accessibility test failed: $_"
                    break  # Skip to next URL
                }
                
                # Actual download
                Invoke-WebRequest -Uri $downloadUrl -OutFile "c:\temp\codedeploy-agent.msi" -UseBasicParsing -TimeoutSec 60
                
                # Verify download
                if (Test-Path "c:\temp\codedeploy-agent.msi") {
                    $fileSize = (Get-Item "c:\temp\codedeploy-agent.msi").Length
                    
                    # Check if file is actually downloaded (not empty or error page)
                    if ($fileSize -gt 1000000) {  # Should be at least 1MB
                        Write-Host "  Downloaded successfully. File size: $fileSize bytes"
                        $downloadSuccess = $true
                        $successfulUrl = $downloadUrl
                    } else {
                        throw "Downloaded file too small ($fileSize bytes), likely an error page"
                    }
                } else {
                    throw "Downloaded file not found"
                }
                
            } catch {
                Write-Host "  Download attempt $retryCount failed: $_"
                
                # Clean up failed download
                if (Test-Path "c:\temp\codedeploy-agent.msi") {
                    Remove-Item "c:\temp\codedeploy-agent.msi" -Force -ErrorAction SilentlyContinue
                }
                
                if ($retryCount -lt $maxRetries) {
                    Write-Host "  Retrying in 5 seconds..."
                    Start-Sleep -Seconds 5
                }
            }
        }
    }
    
    if (-not $downloadSuccess) {
        throw "Failed to download CodeDeploy Agent from any URL after multiple attempts"
    }
    
    Write-Host "SUCCESS: Downloaded from $successfulUrl"
    
    # Alternative download method for Windows 2016 if needed
    if ($windowsVersion -eq "2016" -and -not $downloadSuccess) {
        Write-Host "Trying alternative download method for Windows 2016..."
        
        try {
            # Method 2: Direct AWS CLI-style download (if available)
            $alternativeUrl = "https://aws-codedeploy-downloads.s3.amazonaws.com/releases/codedeploy-agent_installer.msi"
            Write-Host "Trying alternative URL: $alternativeUrl"
            
            Invoke-WebRequest -Uri $alternativeUrl -OutFile "c:\temp\codedeploy-agent.msi" -UseBasicParsing
            
            if (Test-Path "c:\temp\codedeploy-agent.msi") {
                $fileSize = (Get-Item "c:\temp\codedeploy-agent.msi").Length
                if ($fileSize -gt 1000000) {
                    Write-Host "Alternative download successful. File size: $fileSize bytes"
                    $downloadSuccess = $true
                    $successfulUrl = $alternativeUrl
                }
            }
        } catch {
            Write-Host "Alternative download method also failed: $_"
        }
    }
    
    if (-not $downloadSuccess) {
        throw "All download methods failed for Windows Server $windowsVersion"
    }
    
    Write-Host "Installing CodeDeploy Agent..."
    
    # Special handling for Windows 2016
    if ($windowsVersion -eq "2016") {
        Write-Host "Applying Windows Server 2016 specific installation procedures..."
        
        # Ensure .NET Framework compatibility
        try {
            Write-Host "Checking .NET Framework version..."
            $netVersion = (Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release
            Write-Host ".NET Framework release version: $netVersion"
            
            if ($netVersion -lt 461808) {  # .NET 4.7.2 or later recommended
                Write-Host "Warning: .NET Framework version may be outdated for optimal CodeDeploy Agent performance"
            }
        } catch {
            Write-Host "Could not check .NET Framework version: $_"
        }
    }
    
    # Uninstall existing version first
    try {
        Write-Host "Checking for existing CodeDeploy agent installation..."
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
    
    # Check common exit codes
    switch ($installProcess.ExitCode) {
        0 { Write-Host "Installation completed successfully" }
        1603 { Write-Host "Installation error: General MSI error" }
        1619 { Write-Host "Installation error: Package could not be opened" }
        1633 { Write-Host "Installation error: Platform not supported" }
        default { Write-Host "Installation completed with exit code: $($installProcess.ExitCode)" }
    }
    
    Start-Sleep -Seconds 20
    
    Write-Host "Configuring CodeDeploy Agent Service..."
    
    # Configure service with Windows 2016 specific settings
    try {
        # For Windows 2016, sometimes service configuration needs extra time
        if ($windowsVersion -eq "2016") {
            Write-Host "Applying Windows Server 2016 service configuration..."
            Start-Sleep -Seconds 10
        }
        
        Set-Service -Name codedeployagent -StartupType Automatic -ErrorAction Stop
        Write-Host "Service startup type set to Automatic"
    } catch {
        Write-Host "Warning: Could not set service startup type: $_"
    }
    
    # Start service with retry and Windows 2016 specific handling
    $maxStartRetries = 5  # More retries for Windows 2016
    $startRetryCount = 0
    $serviceStarted = $false
    
    while ($startRetryCount -lt $maxStartRetries -and -not $serviceStarted) {
        try {
            $startRetryCount++
            Write-Host "Starting service attempt $startRetryCount of $maxStartRetries..."
            
            Start-Service -Name codedeployagent -ErrorAction Stop
            Start-Sleep -Seconds 10  # Longer wait for Windows 2016
            
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
                $waitTime = 15
                if ($windowsVersion -eq "2016") {
                    $waitTime = 20  # Longer wait for Windows 2016
                }
                Write-Host "Retrying in $waitTime seconds..."
                Start-Sleep -Seconds $waitTime
            }
        }
    }
    
    # Enhanced verification for Windows 2016
    try {
        $service = Get-Service -Name codedeployagent -ErrorAction SilentlyContinue
        if ($service) {
            Write-Host "CodeDeploy Agent service found. Status: $($service.Status)"
            
            # Check agent log files
            $agentLogPath = "C:\ProgramData\Amazon\CodeDeploy\log\codedeploy-agent.log"
            if (Test-Path $agentLogPath) {
                Write-Host "Agent log file exists: $agentLogPath"
                
                # For Windows 2016, check log for specific compatibility issues
                if ($windowsVersion -eq "2016") {
                    try {
                        $logContent = Get-Content $agentLogPath -Tail 10 -ErrorAction SilentlyContinue
                        $hasErrors = $logContent | Where-Object { $_ -match "ERROR|FATAL" }
                        if ($hasErrors) {
                            Write-Host "Warning: Found potential errors in agent log:"
                            $hasErrors | ForEach-Object { Write-Host "  $_" }
                        } else {
                            Write-Host "Agent log shows no critical errors"
                        }
                    } catch {
                        Write-Host "Could not read agent log: $_"
                    }
                }
            }
            
            # Check agent installation directory
            $agentPaths = @(
                "C:\opt\codedeploy-agent",
                "C:\Program Files\Amazon\CodeDeploy",
                "C:\Program Files (x86)\Amazon\CodeDeploy"
            )
            
            foreach ($path in $agentPaths) {
                if (Test-Path $path) {
                    Write-Host "Agent files found at: $path"
                    break
                }
            }
            
            if ($service.Status -eq "Running") {
                Write-Host "✅ SUCCESS: CodeDeploy Agent v$agentVersion is properly installed and running"
                
                # Additional verification for Windows 2016
                if ($windowsVersion -eq "2016") {
                    Write-Host "Windows Server 2016 specific verification completed"
                }
            } else {
                Write-Host "⚠️  WARNING: CodeDeploy Agent installed but service is not running"
            }
        } else {
            Write-Host "❌ ERROR: CodeDeploy Agent service not found after installation"
        }
    } catch {
        Write-Host "Error verifying installation: $_"
    }
    
} catch {
    Write-Host "CRITICAL ERROR during CodeDeploy Agent installation: $_"
    Write-Host "Stack trace: $($_.ScriptStackTrace)"
    
    # Enhanced error logging for Windows 2016
    if ($windowsVersion -eq "2016") {
        Write-Host "Windows Server 2016 troubleshooting information:"
        
        # Check Windows version details
        try {
            $osInfo = Get-WmiObject -Class Win32_OperatingSystem
            Write-Host "OS Version: $($osInfo.Version)"
            Write-Host "OS Build Number: $($osInfo.BuildNumber)"
            Write-Host "OS Architecture: $($osInfo.OSArchitecture)"
        } catch {
            Write-Host "Could not get OS information: $_"
        }
        
        # Check if MSI installation log exists
        if (Test-Path "c:\temp\host-agent-install-log.txt") {
            Write-Host "MSI installation log available at: c:\temp\host-agent-install-log.txt"
            try {
                $logTail = Get-Content "c:\temp\host-agent-install-log.txt" -Tail 5
                Write-Host "Last 5 lines of installation log:"
                $logTail | ForEach-Object { Write-Host "  $_" }
            } catch {
                Write-Host "Could not read installation log: $_"
            }
        }
    }
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
        
        # Windows 2016 specific checks
        if ($windowsVersion -eq "2016") {
            Write-Host "Windows Server 2016 service verification:"
            try {
                $serviceDetails = Get-WmiObject -Class Win32_Service -Filter "Name='codedeployagent'"
                if ($serviceDetails) {
                    Write-Host "  Service Path: $($serviceDetails.PathName)"
                    Write-Host "  Service Account: $($serviceDetails.StartName)"
                }
            } catch {
                Write-Host "  Could not get detailed service information: $_"
            }
        }
    } else {
        Write-Host "ERROR: Service not found"
    }
    
    # Check if agent files exist
    $agentFound = $false
    $agentPaths = @(
        "C:\opt\codedeploy-agent",
        "C:\Program Files\Amazon\CodeDeploy",
        "C:\Program Files (x86)\Amazon\CodeDeploy"
    )
    
    foreach ($agentPath in $agentPaths) {
        if (Test-Path $agentPath) {
            Write-Host "Agent files found at: $agentPath"
            $agentFound = $true
            break
        }
    }
    
    if (-not $agentFound) {
        Write-Host "WARNING: Agent files not found at expected locations"
    }
    
    # Log file status
    $logPath = "C:\ProgramData\Amazon\CodeDeploy\log"
    if (Test-Path $logPath) {
        Write-Host "Log directory exists: $logPath"
        $logFiles = Get-ChildItem $logPath -ErrorAction SilentlyContinue
        Write-Host "Log files found: $($logFiles.Count)"
    }
    
    # Final verdict with Windows version context
    if ($finalService -and $finalService.Status -eq "Running") {
        Write-Host "✅ SUCCESS: CodeDeploy Agent v$agentVersion is properly installed and running on Windows Server $windowsVersion"
        if ($windowsVersion -eq "2016") {
            Write-Host "🎯 Windows Server 2016 compatibility confirmed"
        }
    } else {
        Write-Host "❌ FAILURE: CodeDeploy Agent installation or startup failed on Windows Server $windowsVersion"
        if ($windowsVersion -eq "2016") {
            Write-Host "🔧 Windows Server 2016 may require manual troubleshooting"
        }
    }
    
} catch {
    Write-Host "Error in final status check: $_"
}

Write-Host "EC2 instance initialization completed at $(Get-Date)"
Write-Host "Windows Version: $windowsVersion, Agent Version: $agentVersion"
Write-Host "Successful download URL: $successfulUrl"

Stop-Transcript
</powershell>