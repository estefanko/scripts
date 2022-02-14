Import-Module ActiveDirectory

$Counter = 0

#Lists
$DomainsList = @("DOMAIN1","DOMAIN2","DOMAIN3")
$SecurityGroupsList = @("GROUP1","GROUP2","GROUP3")
$UsersFoundList = @()

ForEach ($Domain in $DomainsList) {
    ForEach ($SecurityGroup in $SecurityGroupsList) {
        
        $GroupMemberLookup = Get-ADGroup -Filter {Name -like $SecurityGroup} -Server $Domain | Get-ADGroupMember -Server $Domain | Get-ADUser -Properties SamAccountName,UserPrincipalName,EmployeeID,GivenName,Surname,Enabled,Description -Server $Domain | Select-Object -Property SamAccountName,@{Name="Domain";Expression={($PSItem.UserPrincipalName -Split "@")[1]}},EmployeeID,GivenName,Surname,Enabled,Description

        $UsersFoundList += $GroupMemberLookup

        #Display output on screen
        $Counter += 1

        Write-Host "($Counter) " -ForegroundColor Green -NoNewline
        Write-Host "$Domain\$SecurityGroup " -ForegroundColor Yellow -NoNewline
        Write-Host "members been found and added to list."
    }
}

#Export user list to CSV
$UsersFoundList | Export-Csv "[PATH].csv" -NoTypeInformation

Read-Host "Press any key to end"