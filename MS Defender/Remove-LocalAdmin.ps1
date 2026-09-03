# Remove-LocalAdmin.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$UserToRemove
)

# 1. Get the Administrators group safely (using SID S-1-5-32-544)
try {
    $adminGroup = Get-LocalGroup -SID "S-1-5-32-544"
}
catch {
    Write-Output "Critical Error: Could not find the Administrators group."
    exit
}

Write-Output "Target Group: $($adminGroup.Name)"
Write-Output "Target User : $UserToRemove"

# 2. Attempt to remove the user
try {
    Remove-LocalGroupMember -Group $adminGroup -Member $UserToRemove -ErrorAction Stop
    Write-Output "SUCCESS: '$UserToRemove' has been removed from local administrators."
}
catch {
    Write-Output "FAILED: Could not remove user. The user might not exist or is not in the group."
    Write-Output "Error Details: $_"
}

# 3. Verification - Show who is left
Write-Output "`n[Verification] Remaining Admins:"
Get-LocalGroupMember -Group $adminGroup | Select-Object Name, PrincipalSource | Format-Table -AutoSize