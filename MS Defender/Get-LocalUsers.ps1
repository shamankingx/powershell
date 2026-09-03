# Get-LocalUsers.ps1
Get-LocalUser | Select-Object Name, Enabled, Description, PasswordRequired, LastLogon | Format-Table -AutoSize