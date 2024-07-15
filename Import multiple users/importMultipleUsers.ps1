# import nodule to remote active directory
Import-Module activedirectory
  
# location to store users file
$ADUsers = Import-csv C:\temp\addmultiUser.csv -Encoding UTF8

# read parameter from users file
foreach ($User in $ADUsers)
{
	# paramters on csv file
		
	#Username (mandatory)
    $Username 	= $User.username
	#Password (mandatory)
    $Password 	= $User.password
	#Firstname to disaplay (mandatory)
    $Firstname 	= $User.firstname
	#Lastname to display (mandatory)
    $Lastname 	= $User.lastname
	#User's OU
    $OU 		= $User.ou
    #Email
    $email      = $User.email
    #Street Address
    $streetaddress = $User.streetaddress
    #City
    $city       = $User.city
    #Zipcode
    $zipcode    = $User.zipcode
    #State
    $state      = $User.state
    #Country
    $country    = $User.country
    #Telephone number
    $telephone  = $User.telephone
    #Job title
    $jobtitle   = $User.jobtitle
    #Company
    $company    = $User.company
    #Department
    $department = $User.department
    #Middle name
    $initials   = $User.initials
    #Script path
    $scriptPath    = $User.scriptPath
    #Description
    $description = $User.description


	# Check existing users
	if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 # Show warning if exist
		 Write-Warning "A user $Username already exist in Active Directory."
	}
	else
	{	
        # Create users with specific parameters
		New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@example.local" `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -DisplayName "$Lastname, $Firstname" `
            -Description $Description `
            -Path $OU `
            -City $city `
            -Company $company `
            -State $state `
            -Zipcode $zipcode `
            -Country $country `
            -Initials $initials `
            -ScriptPath $scriptPath `
            -StreetAddress $streetaddress `
            -OfficePhone $telephone `
            -EmailAddress $email `
            -Title $jobtitle `
            -Department $department `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $True
            
	}
}
