# Get-Admins-Safe.ps1
# Uses cmd.exe /c net localgroup to bypass domain trust errors (Error 1789)

# 1. Get the local name for "Administrators" using the universal SID (S-1-5-32-544)
# This ensures it works on Thai/French/German Windows too.
try {
    $adminGroupName = (Get-LocalGroup -SID "S-1-5-32-544").Name
}
catch {
    # Fallback to English if SID lookup fails
    $adminGroupName = "Administrators"
}

Write-Output "Listing members for group: $adminGroupName"
Write-Output "----------------------------------------"

# 2. Run the legacy NET command which does not crash on trust errors
cmd.exe /c "net localgroup `"$adminGroupName`""
