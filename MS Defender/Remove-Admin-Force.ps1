# Remove-Admin-Force.ps1
# Uses legacy 'net localgroup /delete' to remove users or SIDs forcefully.
# This bypasses PowerShell validation that causes Error 1789.

param(
    [Parameter(Mandatory=$true)]
    [string]$UserToRemove
)

# 1. Try to detect the Administrators group name (Language Safe)
try {
    $groupName = (Get-LocalGroup -SID "S-1-5-32-544").Name
}
catch {
    $groupName = "Administrators"
}

Write-Output "Attempting to force remove: '$UserToRemove' from '$groupName'"

# 2. Run the command
cmd.exe /c "net localgroup `"$groupName`" `"$UserToRemove`" /delete"