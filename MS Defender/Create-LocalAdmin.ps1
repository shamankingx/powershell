# Change password as you need
$password = ConvertTo-SecureString "password" -AsPlainText -Force
# Change username as you need
New-LocalUser "username" -Password $password
# Add new account to Administrators group
Add-LocalGroupMember -Group "Administrators" -Member "username"
