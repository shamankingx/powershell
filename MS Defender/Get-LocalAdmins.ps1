# Get-LocalAdmins.ps1
# This script lists all members of the local 'Administrators' group

$groupName = "Administrators"

try {
    $members = Get-LocalGroupMember -Group $groupName
    $members | Select-Object Name, PrincipalSource, ObjectClass | Format-Table -AutoSize
}
catch {
    Write-Output "Error: Could not find group '$groupName'. If your Windows language is not English, you may need to edit the script to use the localized group name."
}