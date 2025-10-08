```powershell
<#
.SYNOPSIS
    Export Microsoft 365 MFA registration and enforcement status for all users.

.DESCRIPTION
    This script connects to Microsoft Graph and gathers MFA information from:
      - Per-user MFA settings
      - Conditional Access (CA) policies enforcing MFA
      - Registered MFA methods for each user

    The result is saved as a CSV file (MFAStatus.csv) for audit or compliance review.

.REQUIREMENTS
    PowerShell 7+
    Microsoft Graph PowerShell SDK
    Permissions: User.Read.All, Policy.Read.All, Directory.Read.All, UserAuthenticationMethod.Read.All
#>

#--------------------------------------------------------------
#  Step 1: Import and connect to Microsoft Graph
#--------------------------------------------------------------
# Load Microsoft Graph module (install if missing)
# Install-Module Microsoft.Graph -Scope CurrentUser
#--------------------------------------------------------------
Write-Host "🔗 Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "User.Read.All","Policy.Read.All","Directory.Read.All","UserAuthenticationMethod.Read.All"

#--------------------------------------------------------------
#  Step 2: Retrieve user list with required properties
#--------------------------------------------------------------
Write-Host "📋 Fetching all users from your tenant..." -ForegroundColor Cyan
$users = Get-MgUser -All -Property "id,displayName,userPrincipalName,strongAuthenticationRequirements"

#--------------------------------------------------------------
#  Step 3: Retrieve Conditional Access policies that enforce MFA
#--------------------------------------------------------------
Write-Host "🔎 Checking Conditional Access policies that require MFA..." -ForegroundColor Cyan
$CAPolicies = Get-MgIdentityConditionalAccessPolicy -All | Where-Object {
    $_.GrantControls.BuiltInControls -contains "mfa" -and $_.State -eq "enabled"
}
Write-Host "✅ Found $($CAPolicies.Count) MFA-enforcing Conditional Access policies." -ForegroundColor Green

#--------------------------------------------------------------
#  Step 4: Cache user group memberships for CA policy evaluation
#--------------------------------------------------------------
Write-Host "👥 Collecting group memberships for all users (this may take a moment)..." -ForegroundColor Cyan
$groupMembership = @{}
foreach ($user in $users) {
    $groupMembership[$user.Id] = (Get-MgUserMemberOf -UserId $user.Id -All | Select-Object -ExpandProperty Id)
}

# Prepare array for final results
$results = @()

#--------------------------------------------------------------
#  Step 5: Loop through each user to check MFA status
#--------------------------------------------------------------
foreach ($user in $users) {
    try {
        # --- Check per-user MFA setting ---
        $mfaState = "Disabled"
        $mfaRequirement = $user.StrongAuthenticationRequirements
        if ($mfaRequirement) {
            foreach ($req in $mfaRequirement) {
                if ($req.State -in @("Enabled","Enforced")) {
                    $mfaState = "Enabled"
                    break
                }
            }
        }

        # --- Check registered MFA methods ---
        $methods = Get-MgUserAuthenticationMethod -UserId $user.Id -ErrorAction SilentlyContinue
        $mfaMethods = @()
        foreach ($method in $methods) {
            $type = $method.AdditionalProperties['@odata.type']
            switch -Regex ($type) {
                "microsoft.graph.microsoftAuthenticatorAuthenticationMethod" { $mfaMethods += "Microsoft Authenticator" }
                "microsoft.graph.phoneAuthenticationMethod"                   { $mfaMethods += "Phone (SMS/Call)" }
                "microsoft.graph.fido2AuthenticationMethod"                    { $mfaMethods += "FIDO2 Security Key" }
                "microsoft.graph.softwareOathAuthenticationMethod"             { $mfaMethods += "OATH Token" }
                "microsoft.graph.emailAuthenticationMethod"                    { $mfaMethods += "Email" }
                "microsoft.graph.tempAccessPassAuthenticationMethod"           { $mfaMethods += "Temporary Access Pass" }
            }
        }

        $isRegistered = if ($mfaMethods.Count -gt 0) { "Yes" } else { "No" }

        # --- Check Conditional Access MFA enforcement ---
        $caApplies = $false
        foreach ($policy in $CAPolicies) {
            $includeUsers = $policy.Conditions.Users.IncludeUsers
            $includeGroups = $policy.Conditions.Users.IncludeGroups
            $excludeUsers = $policy.Conditions.Users.ExcludeUsers
            $excludeGroups = $policy.Conditions.Users.ExcludeGroups

            # Skip if the user is excluded
            if ($excludeUsers -contains $user.Id) { continue }
            if ($excludeGroups) {
                $excludedGroupMatch = $groupMembership[$user.Id] | Where-Object { $excludeGroups -contains $_ }
                if ($excludedGroupMatch) { continue }
            }

            # Apply if the user or their group is included
            if ($includeUsers -contains "All" -or
                $includeUsers -contains $user.Id -or
                ($includeGroups -and ($groupMembership[$user.Id] | Where-Object { $includeGroups -contains $_ }))) {
                $caApplies = $true
                break
            }
        }

        # --- Determine type of MFA enforcement ---
        if ($mfaState -eq "Enabled") {
            $enforcedType = "Per-user MFA"
        }
        elseif ($caApplies) {
            $enforcedType = "Conditional Access MFA"
        }
        else {
            $enforcedType = "None"
        }

        # --- Add user record to results ---
        $results += [PSCustomObject]@{
            UserPrincipalName = $user.UserPrincipalName
            DisplayName       = $user.DisplayName
            MFA_Registered    = $isRegistered
            MFA_Enforced      = $enforcedType
            MFAMethods        = ($mfaMethods -join ", ")
        }
    }
    catch {
        Write-Warning "⚠️ Error processing $($user.UserPrincipalName): $_"
    }
}

#--------------------------------------------------------------
#  Step 6: Export results to CSV
#--------------------------------------------------------------
Write-Host "💾 Exporting results to MFAStatus.csv..." -ForegroundColor Cyan
$results | Export-Csv -Path ".\MFAStatus.csv" -NoTypeInformation -Encoding UTF8

Write-Host "`n🎉 Done! MFA status report exported to MFAStatus.csv" -ForegroundColor Green
Write-Host "You can open it in Excel to review MFA registration and enforcement for all users." -ForegroundColor Yellow
```
