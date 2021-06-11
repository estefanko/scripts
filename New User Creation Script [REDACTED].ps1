Import-Module ActiveDirectory
Import-Module ADSync

#User variables
$UserFirstName = Read-Host "Enter the legal first name of the user"
$UserPreferredName = Read-Host "Enter in the user's preferred first name"
$UserLastName = Read-Host "Enter the legal last name of the user"
$UserFullName = "$UserLastName, $UserPreferredName" #Every other company probably has it as "$UserPreferredName $UserLastName"
$UserInitials = (($UserPreferredName.Substring(0,1) + $UserLastName.Substring(0,1))).ToUpper()

while ($True){
	$UserNameQuestion = Read-Host "Will the user have a regular username? (y/n)"
	$UserNameQuestion = $UserNameQuestion.ToLower()
	
	if ($UserNameQuestion -eq "y"){
		$UserName = ($UserPreferredName.Substring(0,1) + $UserLastName).ToLower() #Gets the first letter of the first name and the last name and puts them together.
		break
	}
	elseif ($UserNameQuestion -eq "n"){
		$UserName = Read-Host "Enter in the user's non-standard username"
		break
	}
	else{
		Write-Host "ERROR: Unacceptable value. Please try again"
	}
}

$UserTitle = Read-Host "Enter in the user's job title"
$UserPhoneExtension = Read-Host "Enter in the user's phone extension" #This will be used for the -Office property since some phone numbers have separate internal numbers that are mapped to their direct dial numbers. The direct dial goes to the -Phone property and the internal extension is for -Office

#User Location Variable
while ($True){
	$UserLocation= Read-Host "Located at Location 1 (1) or Location 2 (2)?"
	$UserLocation= $UserLocation.ToLower()
	
	if ($UserLocation -eq "1"){
		$UserStreetAddress= "LOCATION 1 STREET ADDRESS"
		break
	}
	elseif ($UserLocation -eq "2"){
		$UserStreetAddress= "LOCATION 2 STREET ADDRESS"
		break
	}
	else{
		Write-Host "ERROR: Location not found. Please try again."
	}
}

#Copied variables
$UserCopy = Get-ADUser -Identity (Read-Host "Enter in the username of the user you want to copy permissions from") -Properties MemberOf,Company,Department
$UserMemberOf = $UserCopy.MemberOf #Gets the security/distribution groups of a user you specify and assigns them to this variable
$UserDepartment = $UserCopy.Department
$UserCompany = $UserCopy.Company
$UserCopyPath = $UserCopy.DistinguishedName -Split ",",3 #DistinguishedName is an inherent property that does not need to be called earlier. -Split takes the DistinguishedName and splits it into groups based on the comma delimeter.
$UserPath = $UserCopyPath[2] #Selects the third group in the -Split property. Index starts at group [0] which is why group[2] is the third group.

#Manager Variables
$Manager = Read-Host "Enter in the username of the user's manager"
$UserManager = Get-ADUser -Identity $Manager

#User Email Domain

Switch($UserCompany)
{
	"COMPANY 1"{$EmailDomain= "@COMPANY1.com"} #The $EmailDomain variable doesn't need to be declared before. It's literally made up right here.
	"COMPANY 2"{$EmailDomain= "@COMPANY2.com"}
}

$UserEmailAddress = ($UserName + $EmailDomain) #Also used for the UserPrincipalName (UPN)

#User Password
$UserPassword = Read-Host "Set the user's password (must match domain complexity requirements)" -AsSecureString

#Create User
New-ADUser -Name $UserFullName -GivenName $UserFirstName -Surname $UserLastName -Initials $UserInitials -SamAccountName $UserName -DisplayName $UserFullName -EmailAddress $UserEmailAddress -UserPrincipalName $UserEmailAddress -Title $UserTitle -Office $UserPhoneExtension -AccountPassword $UserPassword -Enabled $True -Manager $UserManager -Department $UserDepartment -Company $UserCompany -StreetAddress $UserStreetAddress -City "COMPANY CITY" -State "FL" -PostalCode "COMPANY ZIP CODE" -Country "US"  -HomePage "www.COMPANY (dot) com" -Path $UserPath -OtherAttributes @{proxyAddresses = ("SMTP:"+ $UserEmailAddress)}

#Add user to group (add user permissions)
$UserMemberOf | Add-ADGroupMember -Members $UserName #Takes the security/distribution groups you've copied and applies them to the user you just created

#Create a user network folder and give the user access to it
New-Item -Path "\\SERVER\FOLDER\$UserName\FOLDER2" -ItemType Directory -Force #Creates the user folder and the scans folder to be shared. -Force creates all neccessary parent folders in the hierarchy if they don't exist already.
$ACL = Get-Acl -Path "\\SERVER\FOLDER\$UserName"
$Rule = New-Object System.Security.AccessControl.FileSystemAccessRule("DOMAINNAME\$UserName","FullControl",3,0,"Allow") #This creates a class constructor that has attributes that you fill in in a specific order. "3" is the inheritance flag that allows combinations of flag values. "0" is the propogation flag.
$ACL.SetAccessRule($Rule)
Set-Acl -Path "\\SERVER\FOLDER\$UserName" -AclObject $ACL

#Sync With AzureAD
Start-ADSyncSyncCycle -PolicyType Delta #PolicyType Delta specifies to only sync the *changes* made in AD with Azure AD.

#Text Output
Write-Host "User Active Directory account has been created"
Write-Host "User SERVER network folder has been created"
Write-Host "User synced with Azure Active Directory"

Start-Sleep -Seconds 5
