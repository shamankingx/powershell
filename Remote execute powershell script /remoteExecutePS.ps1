# Define variables
$ComputerName = "COMPUTERNAME"  # Remote machine name
$DeltaScriptPath = "\path of your script\"  # Sync Delta script path
$InitialScriptPath = "\path of your script\"  # Sync Initial script path

# Display menu options
Write-Host "Select Sync Type:" -ForegroundColor Cyan
Write-Host "1. Sync Delta"
Write-Host "2. Sync Initial"
$choice = Read-Host "Enter your choice (1 or 2)"

# Determine script to run based on user choice
if ($choice -eq "1") {
    $ScriptPath = $DeltaScriptPath
    Write-Host "You selected Sync Delta..." -ForegroundColor Green
}
elseif ($choice -eq "2") {
    $ScriptPath = $InitialScriptPath
    Write-Host "You selected Sync Initial..." -ForegroundColor Green
}
else {
    Write-Host "Invalid choice! Exiting..." -ForegroundColor Red
    exit
}

# Prompt for credentials
$Credential = Get-Credential

# Execute the script remotely
Invoke-Command -ComputerName $ComputerName -ScriptBlock { & $using:ScriptPath } -Credential $Credential
