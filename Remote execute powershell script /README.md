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

2. The target machine must allow PowerShell remoting through the firewall:
   ```powershell
   Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -Enabled True
   
3. The user running the script must have administrative privileges on the remote machine.

## Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/RemoteSync.git
   cd RemoteSync

2. Update the script with the correct paths for:
   - syncdelta.ps1 (for delta sync)
   - syncinitial.ps1 (for initial sync)

## Usage

Run the script using PowerShell:
```powershell
      .\RemoteSync.ps1
```
User Selection Menu
- 1 → Runs Sync Delta (syncdelta.ps1).
- 2 → Runs Sync Initial (syncinitial.ps1).

## Example Execution
```plaintext
Select Sync Type:
1. Sync Delta
2. Sync Initial
Enter your choice (1 or 2): 1
You selected Sync Delta...
PowerShell credential request
Enter credentials to authenticate on mmldcadc01.
```

## Troubleshooting
- If remoting fails, check if WinRM is enabled and firewall rules allow it.
- Ensure the user has sufficient permissions on the remote machine.
- Validate that the script paths exist on the remote machine.

## License
This project is licensed under the MIT License.
