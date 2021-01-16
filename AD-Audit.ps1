#PowerShell script to output users and user properties from Active Directory into a CSV file

Import-Module ActiveDirectory

$FileName = Read-Host "Enter in what you want the filename to be"

Get-ADUser -Filter * -Properties DisplayName,SamAccountName,EmailAddress,LastLogonDate,Department,Title,Company | Export-Csv C:\Users\administrator.SHAWDEV\Documents\$FileName.csv -NoTypeInformation

Write-Output "Your file has been saved to \Documents\$FileName.csv"

Write-Output "Closing this program."

Start-Sleep -Seconds 2