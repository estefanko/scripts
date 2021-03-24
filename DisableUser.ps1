Import-Module ActiveDirectory

#Disable the user and move them to the Disabled users OU
$UserAccount = Read-Host -Prompt "Enter the username of the account you'd like to disable"
$UserGUID= Get-ADUser -Identity $UserAccount -Properties ObjectGUID
$DisabledOUGUID = Get-ADOrganizationalUnit -Identity "OU=Users,OU=Disabled,DC=[REDACTED],DC=[REDACTED]" -Properties ObjectGUID #MAKE SURE TO CHANGE THE DOMAIN CONTROLLERS

Disable-ADAccount -Identity $UserGUID
Move-ADObject -Identity $UserGUID -TargetPath $DisabledOUGUID

Write-Host "Successfully disabled AD Account $UserAccount"
Write-Host "Successfully moved $UserAccount to Disabled\Users Organizational Unit"

#Set account description to the time it was disabled
$CurrentDate = Get-Date -Format g #"g" is .NET date formatting not specified in the PowerShell help files itself
$UserDescription = "Disabled on $CurrentDate"
Set-ADUser -Identity $UserAccount -Description $UserDescription
Write-Host "Set user description to disabled date"

#Remove user from security and distribution groups
$UserMemberOf = Get-ADUser -Identity $UserAccount -Properties MemberOf
$UserGroups = $UserMemberOf.MemberOf

$UserGroups | Remove-ADGroupMember -Members $UserAccount -Confirm:$False #-Confirm:$False disables the interactive prompt asking to confirm if you want to remove users from a security/distribution group

Start-Sleep -Seconds 5
