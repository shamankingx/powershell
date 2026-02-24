# ==========================================
# Disable Microsoft Copilot (Windows + M365)
# Optimized for Windows 11 / AVD
# ==========================================

<#
Create by Warawuth Phralabraksa
Create date 24/Feb/2026
Disable Microsoft Copilot and Related Background Components on Windows 11 (AVD)
###Objective
This script is designed to fully disable Microsoft Copilot and related background services on Windows 11, particularly in Azure Virtual Desktop (AVD) environments, to:
-Reduce excessive CPU consumption
-Reduce memory usage (WebView2 processes)
-Improve multi-session host performance
-Prevent Copilot from auto-starting or reinstalling
-Disable Microsoft 365 connected experiences related to Copilot
This is especially important in multi-user virtual desktop environments where background WebView2 processes can multiply per session.
#>

Write-Host "Disabling Windows Copilot..."

# 1. Disable Windows Copilot
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f

# 2. Disable Microsoft 365 Copilot / Connected Experiences
Write-Host "Disabling Microsoft 365 Copilot..."

reg add "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common\Privacy" /v ConnectedExperiencesEnabled /t REG_DWORD /d 0 /f

# Explicit M365 Copilot policy key (if supported in build)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common\Copilot" /v DisableCopilot /t REG_DWORD /d 1 /f

# 3. Disable WebView2 Background Mode
Write-Host "Disabling WebView2 background mode..."

reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f

# 4. Disable Edge Startup Preloading
Write-Host "Disabling Edge preload..."

reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v AllowPrelaunch /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader" /v AllowTabPreloading /t REG_DWORD /d 0 /f

# 5. Disable Background Apps Globally
Write-Host "Disabling background apps..."

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v LetAppsRunInBackground /t REG_DWORD /d 2 /f

# 6. Remove Copilot App (if exists)
Write-Host "Checking for Copilot AppX..."

Get-AppxPackage *copilot*
Get-AppxPackage -AllUsers *copilot* | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxProvisionedPackage -Online | Where DisplayName -like "*copilot*" | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

# 7. Disable Copilot Scheduled Tasks
Write-Host "Disabling Copilot scheduled tasks..."

Get-ScheduledTask | Where TaskName -like "*Copilot*" | Disable-ScheduledTask -ErrorAction SilentlyContinue

# 8. Kill Running Copilot Processes
Write-Host "Terminating running Copilot processes..."

taskkill /f /im msedgewebview2.exe 2>$null
taskkill /f /im copilot.exe 2>$null
taskkill /f /im m365copilot.exe 2>$null

Write-Host "Completed. A reboot is required."
