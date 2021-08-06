Import-Module ActiveDirectory

While ($True){

    #Generate a random-ish password
    $MinimumPasswordLength = 110
    $MaximumPasswordLength = 128
    $PasswordLength = Get-Random -Minimum $MinimumPasswordLength -Maximum $MaximumPasswordLength
    $MinimumNonAlphaNumericCharacters = 30
    $MaximumNonAlphaNumericCharacters = 50
    $RandomNonAlphaNumericCharacters = Get-Random -Minimum $MinimumNonAlphaNumericCharacters -Maximum $MaximumNonAlphaNumericCharacters
    Add-Type -AssemblyName System.Web
    $GeneratedPassword = [System.Web.Security.Membership]::GeneratePassword($PasswordLength, $RandomNonAlphaNumericCharacters)
    $SecurePassword = ConvertTo-SecureString -String $GeneratedPassword -AsPlainText -Force

    #Get the user information
    $UserAccount = Read-Host -Prompt "Enter the username of the account you'd like to disable"
    $UserGUID= Get-ADUser -Identity $UserAccount -Properties ObjectGUID

    #Reset password for the user
    Set-ADAccountPassword -Identity $UserGUID -NewPassword $SecurePassword -Confirm:$False #-Confirm:$False disables the interactive prompt
    Write-Host "Reset the password for $UserAccount"

    #Disable User and move them to the disabled users OU
    $DisabledOUGUID = Get-ADOrganizationalUnit -Identity "OU=Users,OU=Disabled,DC=[REDACTED],DC=[REDACTED]" -Properties ObjectGUID #MAKE SURE TO CHANGE THE DOMAIN CONTROLLERS
    Disable-ADAccount -Identity $UserGUID
    Move-ADObject -Identity $UserGUID -TargetPath $DisabledOUGUID

    Write-Host "Disabled the AD Account for $UserAccount"
    Write-Host "Moved $UserAccount to Disabled\Users Organizational Unit"

    #Set account description to the time it was disabled
    $CurrentDate = Get-Date -Format g #"g" is .NET date formatting not specified in the PowerShell help files itself
    $UserDescription = "Disabled on $CurrentDate"
    Set-ADUser -Identity $UserAccount -Description $UserDescription
    Write-Host "Set $UserAccount description to the current time"

    #Get the security and distribution groups and add them to the Telephone Notes section of the user properties
    [string]$UserGroups = Get-ADPrincipalGroupMembership -Identity $UserAccount | Select-Object -ExpandProperty Name
    Get-ADUser -Identity $UserAccount -Properties info | Set-ADUser -Replace @{info = "Removed from security/distribution groups: `n`r`n`r$UserGroups"} #I don't know how to format this properly
    Write-Host "Added security/distribution groups to the Notes section of the Telephone tab in the AD user properties"

    #Remove user from security and distribution groups
    $UserMemberOF = Get-ADUser -Identity $UserAccount -Properties MemberOf
    $MemberOfGroups = $UserMemberOF.MemberOf
    $MemberOfGroups | Remove-ADGroupMember -Members $UserAccount -Confirm:$False
    Write-Host "Remove security/distriution group access from $UserAccount"

    #Loop
    $LoopInput = "Do you want to disable another account? (y/n)"
    $LoopAnswer = $LoopInput.ToLower()

    if ($LoopAnswer -eq ("y" -or "yes")){
        break
    }

}

Write-Host "Closing Program"

Start-Sleep -Seconds 5