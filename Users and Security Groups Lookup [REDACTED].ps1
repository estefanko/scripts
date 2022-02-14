Import-Module ActiveDirectory

#Numbers
$Counter = 0
$ErrorCounter = 0

#User Lists
$UserLookupList = @()
$ErroUsersList = @()

#Import data
$CSVFile = Import-Csv -Path "[PATH].csv"

#Find all the users and their security groups and add them to lists. Security groups will all be in one cell you so must use Excel "text-to-columns" feature to separate the groups.
ForEach ($User in $CSVFile){
    try{
        $UserIdentifier = $User."Federation ID"

        $UserLookup = Get-ADUser -Identity $UserIdentifier -Properties DistinguishedName,SamAccountName,GivenName,Surname,MemberOf -Server hertz.net | Select-Object -Property DistinguishedName,SamAccountName,GivenName,Surname,@{name="MemberOf";expression={$PSItem.MemberOf -join ";"}}

        $UserLookupList += $UserLookup

        #Output to display

        $Counter += 1

        Write-Host "($Counter) " -ForegroundColor Green -NoNewline
        Write-Host "$UserIdentifier " -ForegroundColor Yellow -NoNewline
        Write-Host "was found an added to the list." -ForegroundColor Green
    }
    #Most likely error will be that the user couldn't be found
    catch{
        
        #Output to display

        $ErrorUsersList += $UserIdentifier
        $ErrorCounter += 1

        Write-Host "($ErrorCounter) " -BackgroundColor Black -ForegroundColor Red -NoNewline
        Write-Host "$UserIdentifier " -BackgroundColor Black -ForegroundColor Red -NoNewline
        Write-Host "had an error." -BackgroundColor Black

    }
}

#Output the lists to the files
$UserLookupList | Export-Csv -Path "[PATH].csv" -NoTypeInformation
$ErroUsersList | Out-File -FilePath "[PATH].txt"

Read-Host "Press any key to end the script"