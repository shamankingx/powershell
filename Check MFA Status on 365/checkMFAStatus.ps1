# Get all users in the tenant
Write-Host "Fetching user list..."
$users = Get-MgUser -All

# Create array to store results
$results = @()

# Loop through users to get MFA registration methods
foreach ($user in $users) {
    try {
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
            }
        }

        $mfaEnabled = if ($mfaMethods.Count -gt 0) { "Enabled" } else { "Disabled" }

        $results += [PSCustomObject]@{
            UserPrincipalName = $user.UserPrincipalName
            DisplayName       = $user.DisplayName
            MFAStatus         = $mfaEnabled
            MFAMethods        = ($mfaMethods -join ", ")
        }

    } catch {
        Write-Warning "Failed to check MFA for $($user.UserPrincipalName)"
    }
}

# Export results to CSV
$results | Export-Csv -Path ".\MFAStatus.csv" -NoTypeInformation -Encoding UTF8

Write-Host "`nMFA status report has been exported to: MFAStatus.csv" -ForegroundColor Green
