Import-Module ActiveDirectory

#Import the most recent CSV file
$CSVFile = (Import-Csv (Get-ChildItem -Path "[REDACTED]\*.csv" -File | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1)) | Sort-Object -Property "Last Name"

#Remove the previous log file
if ((Test-Path -Path "[REDACTED].txt") -eq $True){
    Remove-Item -Path "[REDACTED].txt"
}

#Start of Output
Write-Host "Updating user information." -ForegroundColor Yellow
Write-Host "`r`nErrors are shown below:`r`n" -ForegroundColor Red -BackgroundColor Black

#Select the specified data for each user in the CSV file and iterate over each user object and update Active Directory properties
ForEach ($User in $CSVFile){
    try{
        #Manager Data
        $Manager = $User.Manager -Split ",",2
        $ManagerFirstName = $Manager[1]
        $ManagerLastName = $Manager[0]
        $ManagerObject = Get-ADUser -Filter {(GivenName -like $ManagerFirstName) -and (Surname -like $ManagerLastName)}

        #User data
        $FirstName = $User."First Name"
        $LastName = $User."Last Name"
        $UserObject = Get-ADUser -Filter {(GivenName -like $FirstName) -and (Surname -like $LastName)}
        $Department = $User."Department Name"
        $Title = $User."Job Title"
        $WorkLocation = $User."Work Location"

        if ($WorkLocation -like [REDACTED]){
            $StreetAddress = "[REDACTED]"
        }
        elseif ($WorkLocation -like "[REDACTED]") {
            $StreetAddress = "[REDACTED]"
        }
        else {
            $StreetAddress = "Remote"
        }
        
        #Change user properties based on the the CSV data
        if ($Null -eq $ManagerObject) { #ManagerObject -eq $null would be the case if either their legal first name is different than the one in Active Directory (e.g. Michael vs Mike). We don't update their manager in this case because otherwise it makes the field blank and messes up the org chart.
            Set-ADUser -Identity $UserObject -Department $Department -Title $Title -StreetAddress $StreetAddress
        }
        else {
            Set-ADUser -Identity $UserObject -Manager $ManagerObject -Department $Department -Title $Title -StreetAddress $StreetAddress
        }
    }

    #If this error appears for a user with an AD account, check the for their first name in the CSV data vs their first name in AD. Often it will be a difference between their legal first name in the CSV and their nickname in AD (e.g. Michael vs Mike).
    catch [System.Management.Automation.ParameterBindingException]{
        Write-Host "$FirstName $LastName" -ForegroundColor Red -BackgroundColor Black -NoNewline
        Write-Host " was not found in Active Directory"
        "$FirstName $LastName" | Out-File -FilePath "[REDACTED].txt" -Append
    }
}

Write-Host "`r`n`r`nThe error log can be found at [REDACTED].txt`r`n`r`n" -ForegroundColor Yellow

Read-Host "Press enter to exit the program"
