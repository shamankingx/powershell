# Remote PowerShell Sync Execution

This PowerShell script allows users to remotely execute **Sync Delta** or **Sync Initial** operations on a specified Windows server using PowerShell remoting for example.
You can change to another scripts as you needed.

## Features
- **User Selection:** Choose between Sync Delta or Sync Initial before execution.
- **Credential Prompt:** Secure authentication via `Get-Credential`.
- **Remote Execution:** Runs the selected PowerShell script on the target machine via `Invoke-Command`.

## Prerequisites
1. **PowerShell Remoting (WinRM) must be enabled** on the target machine:
   ```powershell
   Enable-PSRemoting -Force
