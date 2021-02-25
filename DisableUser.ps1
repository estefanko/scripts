Import-Module ActiveDirectory

$UserAccount = Read-Host -Prompt "Enter the username of the account you'd like to disable"
$UserGUID= Get-ADUser -Identity $UserAccount -Properties ObjectGUID
$DisabledOUGUID = Get-ADOrganizationalUnit -Identity "OU=Users,OU=Disabled,DC=[REDACTED],DC=[REDACTED]" -Properties ObjectGUID #MAKE SURE TO CHANGE THE DOMAIN CONTROLLERS

Disable-ADAccount -Identity $UserGUID
Move-ADObject -Identity $UserGUID -TargetPath $DisabledOUGUID

Write-Host "Successfully disabled AD Account $UserAccount"
Write-Host "Successfully moved $UserAccount to Disabled\Users Organizational Unit"

$CurrentDate = Get-Date -Format g #"g" is .NET date formatting not specified in the PowerShell help files itself
$UserDescription = "Disabled on $CurrentDate"
Set-ADUser -Identity $UserAccount -Description $UserDescription
Write-Host "Set user description to disabled date"

Start-Sleep -Seconds 5