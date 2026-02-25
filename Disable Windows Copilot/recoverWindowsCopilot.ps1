# ==========================================
# Recover Microsoft Copilot (Windows + M365)
# Rollback Script for Windows 11 / AVD
# ==========================================

Write-Host "Restoring Windows Copilot..."

# 1. Re-enable Windows Copilot
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /f 2>$null

# 2. Re-enable Microsoft 365 Connected Experiences
Write-Host "Restoring Microsoft 365 Copilot settings..."

reg delete "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common\Privacy" /v ConnectedExperiencesEnabled /f 2>$null
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common\Copilot" /v DisableCopilot /f 2>$null

# 3. Re-enable WebView2 Background Mode
Write-Host "Restoring WebView2 background mode..."

reg delete "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v BackgroundModeEnabled /f 2>$null

# 4. Re-enable Edge Startup Preloading
Write-Host "Restoring Edge preload settings..."

reg delete "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v AllowPrelaunch /f 2>$null
reg delete "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader" /v AllowTabPreloading /f 2>$null

# 5. Re-enable Background Apps
Write-Host "Restoring background apps permission..."

reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v LetAppsRunInBackground /f 2>$null

# 6. Re-enable Copilot Scheduled Tasks
Write-Host "Re-enabling Copilot scheduled tasks..."

Get-ScheduledTask | Where TaskName -like "*Copilot*" | Enable-ScheduledTask -ErrorAction SilentlyContinue

# 7. Reinstall Copilot App (if provisioned package was removed)
Write-Host "Attempting to restore Copilot AppX (if available)..."

Get-AppxPackage -AllUsers *copilot* | ForEach-Object {
    Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" -ErrorAction SilentlyContinue
}

Write-Host "Recovery process completed."
Write-Host "A reboot is required to fully restore functionality."
