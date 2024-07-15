# Function to prompt the user to enter the Active Directory IP or FQDN
Function Get-ADServer {
    return Read-Host -Prompt "Enter Active Directory IP or FQDN: "
}

# Function to create PSCredential object
Function Get-Credentials {
    param (
        [string]$username,
        [SecureString]$password
    )

    return New-Object System.Management.Automation.PSCredential ($username, $password)
}

# Function to test AD authentication
Function Test-ADAuthentication {
    param (
        [PSCredential]$credential,
        [string]$ldapPath
    )
    try {
        # Convert secure string password to plain text
        $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password))
        # Create DirectoryEntry object for LDAP authentication
        $entry = New-Object DirectoryServices.DirectoryEntry("LDAP://$ldapPath", $credential.UserName, $password)
        # Check if authentication was successful
        if ($null -ne $entry.psbase.name) {
            Write-Host "Authentication successful for $($credential.UserName)" -ForegroundColor Green -BackgroundColor Black
            return $true
        } else {
            Write-Host "Authentication failed for $($credential.UserName)" -ForegroundColor Red -BackgroundColor Black
            return $false
        }
    } catch {
        # Catch any errors during authentication
        Write-Host "Error: $_" -ForegroundColor Yellow -BackgroundColor Black
        return $false
    }
}

# Function to prompt for username and check existence
Function Get-UsernameAndCheckExistence {
    param (
        [string]$ldapPath
    )

    do {
        # Prompt user for username to check
        $usernameToCheck = Read-Host -Prompt "Enter username to check (or type 'exit' to quit): "
        # Check if user wants to exit
        if ($usernameToCheck -eq "exit") {
            exit
        }
        # Check if user exists in Active Directory
        $exists = Test-ADUserExistence -username $usernameToCheck -ldapPath $ldapPath
        if ($exists) {
            # Prompt user for password
            $password = Read-Host -AsSecureString -Prompt "Enter password for $usernameToCheck"
            # Get credentials object
            $credentials = Get-Credentials -username $usernameToCheck -password $password
            # Authenticate user against Active Directory
            if (Test-ADAuthentication -credential $credentials -ldapPath $ldapPath) {
                # Authentication succeeded, you can perform further actions here
            }
        }
    } while ($true)
}

# Function to test if user exists in Active Directory
Function Test-ADUserExistence {
    param (
        [string]$username,
        [string]$ldapPath
    )
    try {
        # Create DirectoryEntry object for LDAP search
        $entry = New-Object DirectoryServices.DirectoryEntry("LDAP://$ldapPath")
        $searcher = [System.DirectoryServices.DirectorySearcher]$entry
        # Filter to search for the specified username
        $searcher.Filter = "(&(objectCategory=person)(objectClass=user)(sAMAccountName=$username))"
        # Perform the search
        $result = $searcher.FindOne()

        # Check if user exists
        if ($result -ne $null) {
            Write-Host "User $username exists in Active Directory." -ForegroundColor Green
            return $true
        } else {
            Write-Host "User $username not found in Active Directory." -ForegroundColor Red
            return $false
        }
    } catch {
        # Catch any errors during user existence check
        Write-Host "Error: $_" -ForegroundColor Yellow
        return $false
    }
}

# Example usage:
$ldapPath = Get-ADServer
# Call the function to prompt for username and check existence
Get-UsernameAndCheckExistence -ldapPath $ldapPath
