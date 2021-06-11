Import-Module ActiveDirectory

#Import the most recent CSV file
$CSVFile = Get-ChildItem -Path C:\PaycorScript\Data\*.csv -File | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
$CSVData = Import-Csv -Path $CSVFile

#Select the specified data for each user in the CSV file and iterate over each user object and update Active Directory properties
ForEach ($User in $CSVData){
    try{
        $Manager = $User.Manager -Split ",",2
        $ManagerFirstName = $Manager[1]
        $ManagerLastName = $Manager[0] -Split " ",2
        $ManagerLastName = $ManagerLastName[0]
        $ManagerUsername = ($ManagerFirstName.Substring(0,1)+$ManagerLastName)
        $Department = $User."Department Name"
        $Title = $User."Job Title"
        $FirstName = $User."First Name"
        $LastName = $User."Last Name" -Split " ",2
        $LastNameSplit = $LastName[0]
        $Username = ($FirstName.Substring(0,1)+$LastNameSplit)
        
        #This if-else statement checks if the username has the initials capitalized or if the whole username is lower case (e.g. JSmith vs jsmith)
        if ($Username.Substring(0,2) -eq $Username.Substring(0,2).ToUpper()){
            $ADUser = Get-ADUser -Identity $Username
        }
        else {
            $UsernameLower = $Username.ToLower()
            $ADUser = Get-ADUser -Identity $UsernameLower
        }

        Set-ADUser -Identity $ADUser -Manager $ManagerUsername  -Department $Department -Title $Title
    }
    #Any person in the Excel file, but that doesn't have an AD account should be caught by this statement
    catch [Microsoft.ActiveDirectory.Management.ADIdentityResolutionException]{
        "$FirstName $LastName was not found in Active Directory"
        
    }
}

Read-Host "Press enter to exit the program"
