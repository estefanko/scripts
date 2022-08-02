Import-Module ActiveDirectory

#Initial security group variables
$Forest1BaseInternetGroups = @("REDACTED_base","REDACTEDbrowsers")
$Forest1SocialMediaGroups = @("REDACTED_social_media","REDACTED_Social Media")
$Forest1FileStorageGroup = "REDACTED_filestorage"
$Forest1BoxComGroup = "REDACTED_box_com"
$NewBaseInternetGroup = "REDACTED_Internet_Base"
$NewBaseSocialMediaGroup = "REDACTED_Internet_SocialMedia"
$NewBaseStorageGroup = "REDACTED_Internet_Storage"
$NewBaseBoxComGroup = "REDACTED_Internet_Box_com"
$ErrorUserList = @()
$Date = Get-Date -UFormat "%Y%m%d"

#Check the Forest 2 AD users and reconcile them with the users in the Forest 1 internet groups. If the corresponding Forest 1 account associated with the Forest 2 carLicense attribute contains the old internet groups, then add the Forest 2 account to the new Forest 2 internet groups.

$Forest2Users = Get-ADUser -Filter {Enabled -eq $true} -Properties SamAccountName,carLicense -SearchScope 2 -SearchBase "OU=DomainUsers,OU=[REDACTED],OU=[REDACTED],DC=[REDACTED],DC=[REDACTED]" -Server FOREST2 -ErrorAction SilentlyContinue | Select-Object -Property SamAccountName,@{Name="carLicense";Expression={(-join $PSItem.carLicense)}}

#Export the users the script will take action on for later reference if necessary
$Forest2Users | Export-Csv -Path "C:\Scripts\Logs\Forest 2 users and carLicense $Date.csv"

ForEach ($User in $Forest2Users){
    try{

        #Get user attributes necessary
        $Forest2Identifier = $User.SamAccountName
        $Forest1Identifier = $User.carLicense
        $Forest1Domain = ($User.carLicense -Split "@")[1] #This gets you the corresponding domain a user's account is a part of in the carLicense

        #Lookup the user's primary Forest 1 account based on their Forest 2 carLicense attribute.
        $UserLookup = Get-ADUser -Filter {UserPrincipalName -like $Forest1Identifier} -Server $Forest1Domain -ErrorAction SilentlyContinue
        
        #Get the security groups a user's Forest 1 account is a member of
        $UserGroups= Get-ADPrincipalGroupMembership -Identity $UserLookup.SamAccountName -ResourceContextServer $Forest1Domain -Server $Forest1Domain -ErrorAction SilentlyContinue | Select-Object -Property Name | ForEach-Object {$PSItem.Name -Split "[=}]"} | Where-Object -FilterScript {$PSItem -notlike "@Name{"}

        #Add the user to the new hertz.net internet groups if the user already has corresponding access on their hertz.com account
        if (($Forest1BaseInternetGroups[0] -in $UserGroups) -or ($Forest1BaseInternetGroups[1] -in $UserGroups)){

            Add-ADPrincipalGroupMembership -Identity $Forest2Identifier -MemberOf $NewBaseInternetGroup -Server hertz.net -ErrorAction SilentlyContinue -Confirm:$false

        }
        if (($Forest1SocialMediaGroups[0] -in $UserGroups) -or ($Forest1SocialMediaGroups[1] -in $UserGroups)){

            Add-ADPrincipalGroupMembership -Identity $Forest2Identifier -MemberOf $NewBaseSocialMediaGroup -Server hertz.net -ErrorAction SilentlyContinue -Confirm:$false

        }
        if ($Forest1FileStorageGroup -in $UserGroups){

            Add-ADPrincipalGroupMembership -Identity $Forest2Identifier -MemberOf $NewBaseStorageGroup -Server hertz.net -ErrorAction SilentlyContinue -Confirm:$false

        }
        if ($Forest1BoxComGroup -in $UserGroups){

            Add-ADPrincipalGroupMembership -Identity $Forest2Identifier -MemberOf $NewBaseBoxComGroup -Server hertz.net -ErrorAction SilentlyContinue -Confirm:$false

        }

    }
    catch{

        #Adds the user to an error list to be exported
        $ErrorUserList += "$Forest2Identifier,$Forest1Identifier"

        continue

    }
}

$ErrorUserList | Out-File -FilePath "C:\Scripts\Logs\Internet groups replication users with errors $Date.txt"