# Self-elevate the script to run as administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $arg = "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell -ArgumentList $arg -Verb RunAs
    exit
}

# Prompt for the remote server hostname or IP address
$remoteServer = Read-Host "Enter the hostname or IP address of the remote server"

# Configure TrustedHosts (ensure it's a string)
$trustedHosts = $remoteServer -as [string]
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $trustedHosts -Force

# Loop for command selection
while ($true) {
    # Function to display the menu and get the user's choice
    function Get-UserChoice {
        Write-Host "Select an option:"
        Write-Host "1. Start-ADSyncSyncCycle -PolicyType Delta"
        Write-Host "2. Start-ADSyncSyncCycle -PolicyType Initial"
        Write-Host "Type 'exit' to quit"
        $choice = Read-Host "Enter your choice (1 or 2 or exit)"
        return $choice
    }

    # Get the user's choice
    $choice = Get-UserChoice

    # Check for exit command
    if ($choice -eq 'exit') {
        Write-Host "Exiting script."
        exit
    }

    # Define the script block based on the user's choice
    $scriptBlock = {
        param ($policyType)
        Import-Module ADSync
        Start-ADSyncSyncCycle -PolicyType $policyType
    }

    # Determine the policy type based on the user's choice
    switch ($choice) {
        1 { $policyType = "Delta" }
        2 { $policyType = "Initial" }
        default {
            Write-Host "Invalid choice. Please try again."
            continue
        }
    }

    # Get credentials for the remote session
    $cred = Get-Credential

    # Create a new PowerShell session
    $session = New-PSSession -ComputerName $remoteServer -Credential $cred

    # Execute the command on the remote server using the session
    Invoke-Command -Session $session -ScriptBlock $scriptBlock -ArgumentList $policyType

    # Show notification message
    $notificationMessage = "Command executed on $remoteServer with PolicyType $policyType"
    Write-Host $notificationMessage

    # Remove the session
    Remove-PSSession $session
}

# Prevent the console from closing automatically
Read-Host "Press Enter to exit"
