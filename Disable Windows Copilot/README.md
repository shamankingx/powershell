# Disable Microsoft Copilot (Windows + Microsoft 365)
## Windows 11 / Azure Virtual Desktop (AVD)

---

## 📌 Overview

This PowerShell script disables Microsoft Copilot components at the operating system and Microsoft 365 levels.  
It is designed primarily for:

- Windows 11 Enterprise
- Azure Virtual Desktop (AVD) multi-session hosts
- Environments where Copilot is not required
- Systems experiencing high CPU usage from WebView2 processes

The script applies policy-based configuration changes, removes Copilot packages (if present), disables background execution, and terminates active Copilot-related processes.

---

## 🎯 Objectives

- Prevent Windows Copilot from loading
- Disable Microsoft 365 Copilot functionality
- Reduce WebView2 background CPU consumption
- Stop Edge preloading behavior
- Remove Copilot AppX packages (if applicable)
- Prevent scheduled task reactivation
- Immediately terminate active Copilot processes

---

## 🔧 Configuration Changes Applied

### 1️⃣ Disable Windows Copilot

```powershell
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f
```

---

#### Effect:

- Disables Windows Copilot feature
- Applies to all users on the machine
- Prevents Copilot UI and background components

---

### 2️⃣ Disable Microsoft 365 Copilot

```powershell
reg add "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common\Privacy" /v ConnectedExperiencesEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common\Copilot" /v DisableCopilot /t REG_DWORD /d 1 /f
```

---

#### Effect:

- Disables Microsoft 365 connected experiences
- Explicitly disables M365 Copilot (if supported in current Office build)
- Reduces WebView2-based background activity

---

### 3️⃣ Disable WebView2 Background Mode

```powershell
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f
```

---

#### Effect:

- Prevents WebView2 from running persistent background processes
- Reduces msedgewebview2.exe instances
- Directly improves CPU and RAM usage

---

### 4️⃣ Disable Edge Startup Preloading

```powershell
reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v AllowPrelaunch /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader" /v AllowTabPreloading /t REG_DWORD /d 0 /f
```

---

#### Effect:

- Stops Edge prelaunch at Windows startup
- Reduces login-time performance spikes

---

### 5️⃣ Disable Background Apps Globally

```powershell
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v LetAppsRunInBackground /t REG_DWORD /d 2 /f
```

---

#### Effect:

- Prevents Microsoft Store apps from running in background
- Recommended for AVD multi-session hosts

---

### 6️⃣ Remove Copilot AppX (If Installed)

```powershell
Get-AppxPackage *copilot*
Get-AppxPackage -AllUsers *copilot* | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxProvisionedPackage -Online | Where DisplayName -like "*copilot*" | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
```

---

#### Effect:

- Detects Copilot AppX package
- Removes for all existing users
- Removes provisioned package to prevent installation for new users

Note: Some Windows builds integrate Copilot as a system component and may not expose an AppX package.

---

### 7️⃣ Disable Copilot Scheduled Tasks

```powershell
Get-ScheduledTask | Where TaskName -like "*Copilot*" | Disable-ScheduledTask -ErrorAction SilentlyContinue
```

---

#### Effect:

- Prevents automatic Copilot background activation

---

### 8️⃣ Terminate Running Copilot Processes

```powershell
taskkill /f /im msedgewebview2.exe 2>$null
taskkill /f /im copilot.exe 2>$null
taskkill /f /im m365copilot.exe 2>$null
```

---

#### Effect:

- Immediately stops active Copilot and WebView2 processes
- Provides instant CPU relief
- Suppresses errors if processes are not running

---

## 🚀 Full Script

```powershell
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

# 2. Disable Microsoft 365 Copilot
Write-Host "Disabling Microsoft 365 Copilot..."

reg add "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common\Privacy" /v ConnectedExperiencesEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common\Copilot" /v DisableCopilot /t REG_DWORD /d 1 /f

# 3. Disable WebView2 Background Mode
Write-Host "Disabling WebView2 background mode..."

reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f

# 4. Disable Edge Startup Preloading
Write-Host "Disabling Edge preload..."

reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v AllowPrelaunch /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader" /v AllowTabPreloading /t REG_DWORD /d 0 /f

# 5. Disable Background Apps
Write-Host "Disabling background apps..."

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v LetAppsRunInBackground /t REG_DWORD /d 2 /f

# 6. Remove Copilot App (if exists)
Write-Host "Checking for Copilot AppX..."

Get-AppxPackage *copilot*
Get-AppxPackage -AllUsers *copilot* | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxProvisionedPackage -Online | Where DisplayName -like "*copilot*" | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

# 7. Disable Scheduled Tasks
Write-Host "Disabling Copilot scheduled tasks..."

Get-ScheduledTask | Where TaskName -like "*Copilot*" | Disable-ScheduledTask -ErrorAction SilentlyContinue

# 8. Kill Running Processes
Write-Host "Terminating running Copilot processes..."

taskkill /f /im msedgewebview2.exe 2>$null
taskkill /f /im copilot.exe 2>$null
taskkill /f /im m365copilot.exe 2>$null

Write-Host "Completed. A reboot is required."
```

---

## 🔁 Post-Execution Requirement
A reboot is required:

```powershell
Restart-Computer
```

---

## 🏢 Recommended Deployment (AVD Best Practice)
1. Apply script to Golden Image
2. Reboot and validate CPU usage
3. Capture new image
4. Redeploy session hosts

---

## ⚠ Considerations
- Some WebView2 processes may still appear if required by:
  - Windows Search
  - Widgets
  - Other Office components
- This script focuses specifically on disabling Copilot-related components.

---

## 👨‍💻 Author
Warawuth Phralabraksa
