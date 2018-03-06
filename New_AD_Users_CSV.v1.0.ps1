#=================== AD AXS
$userid='ad.axs.com\systemadmin'
$pwd= get-content C:\Server_PS_Scripts\credentials\credSYSTEM.txt | convertto-securestring
$creds = New-Object System.Management.Automation.PSCredential($userid,$pwd)

#==================== OFFICE 365
#Capture administrative credential for future connections.
$userid1='sysadm@axs.com'
$pwd1= get-content C:\Server_PS_Scripts\credentials\cred1.txt | convertto-securestring
$creds1 = New-Object System.Management.Automation.PSCredential($userid1,$pwd1)

#================================================================================================

$path = Split-Path -parent "C:\Server_PS_Scripts\*.*"

#Define CSV and log file location variables
#they have to be on the same location as the script

$csvfile = $path + "\users\usertestFile.csv"
$logfile = $path + "\logs\logfile_user_creation.txt"
$i        = 0
$date     = Get-Date

#Define variable for a server with AD web services installed

$ADServer = 'DDDC01'


#Get Admin accountb credential

#$creds = Get-Credential 

#Import Active Directory Module

Import-Module ActiveDirectory

#Set the OU to add new users.

#$location = "OU=LA, OU=Users, OU=Z-Users, DC=ad, DC=axs, DC=com"
Connect-MsolService -Credential $creds1

#Import CSV file and update users in the OU with details in the fileh
#Create the function script to update the users

Function Create-ADUsers {

"AD user creation logs for( " + $date + "): " | Out-File $logfile -append
"--------------------------------------------" | Out-File $logfile -append

Import-Csv -Path $csvfile  | ForEach-Object { 

$GivenName = $_.'First Name'
$Surname = $_.'Last Name'
$DisplayName = $_.'Display Name'
$sam = $_.'Logon Name'
$StreetAddress = $_.'Street'
$City = $_.City
$State = $_.State
$PostCode = $_.'Zip/Postal Code' 
$Country = $_.'Country/Region' 
$Title = $_.Title
$Company = $_.Company
$Description = $_.Description
$Department = $_.Department
$Office = $_.Office
$Phone = $_.Phone
$Mail = $_.Email
$Manager = $_.Manager
$Status = $_.'Account Status'
$OU = $_.'ParentOU'
$password = $_.Password
$ManagerDN = (Get-ADUser -server $ADServer -Credential $creds -LDAPFilter "(DisplayName=$Manager)").DistinguishedName #Manager required in DN format


#change country to to be landcodes in order for AD to accept them format, 
#For example,United Kingdom is GB
If ($Country -eq "United State") {$Country = "US"} 
If ($Country -eq "London") {$Country = "UK"}

#Define samAccountName to use with NewADUser in the format firstName.LastName

#$sam = $GivenName.ToLower() + "." + $Surname.ToLower()

#Define domain to use for UserPrincipalName (UPN)

$Domain = '@ad.axs.comm'


#Define UerPrincipalname 

$UPN = $sam + $Domain

#Now create new users using info from CSV
#First check whether the user exist, if use is not in ad, create it

Try   { $nameinAD = Get-ADUser -server $ADServer -Credential $creds -LDAPFilter "(sAMAccountName=$sam)" }
    Catch { }
    If(!$nameinAD)
    {
      $i++


#Create new AD accounts using the info from the CSV
#If "-enabled $TRUE" is not set, the account will be disabled by default

$setpassword = ConvertTo-SecureString -AsPlainText $password -force
      New-ADUser $sam -server $ADServer -Credential $creds `
      -GivenName $GivenName -ChangePasswordAtLogon $TRUE `
      -Surname $Surname -DisplayName $DisplayName -Office $Office `
      -Description $Description -EmailAddress $Mail `
      -StreetAddress $StreetAddress -City $City -State $State  `
      -PostalCode $PostCode -Country $Country -UserPrincipalName $UPN `
      -Company $Company -Department $Department -enabled $TRUE `
      -Title $Title -OfficePhone $Phone -AccountPassword $setpassword  

 #Set manager property#necessary as manager may not exist while the users are being created
 #with New-ADUser command above. Manager switch only accepts name in DN format

 Set-ADUser -server $ADServer -Credential $creds -Identity $sam -Manager $ManagerDN

 #Define DN to use in the  Move-ADObject command

 $dn = (Get-ADUser -server $ADServer -Credential $creds -Identity $sam).DistinguishedName
 
 # Move the users to the OU set above. 

 Move-ADObject -server $ADServer -Credential $creds -Identity $dn -TargetPath $OU
 
 # Rename the object to a good looking name to avoid displaying sAMAccountNames (eg tests1.user1)
 #First create usernames as DNs, Rename-ADObject only accepts DistinguishedNames
 
 $newdn = (Get-ADUser -server $ADServer -Credential $creds -Identity $sam).DistinguishedName
 Rename-ADObject -server $ADServer -Credential $creds -Identity $newdn -NewName $DisplayName
 
 #Update log file with users created successfully

 $DisplayName + " Created successfully" | Out-File $logfile -append

 

New-MsolUser -DisplayName $DisplayName -FirstName $GivenName -LastName $Surname -UserPrincipalName $Mail -UsageLocation $Country  -LicenseAssignment outboxtechnology:STANDARDPACK -Password P@ssw0rd1! -ForceChangePassword $TRUE | Export-Csv -Path "C:\Server_PS_Scripts\logs\NewAccountResults.csv"


 
}

Else
    { #Update log file with users not created  
      $DisplayName + " Not Created - User Already Exists" | Out-File $logfile -append
    }


   }


 }
# Run the function script 
Create-ADUsers

  

#Get-ADUser  -Server localhost:60000 -SearchBase "DC=AppNC" -filter { Title -eq "Account Lead" -and Office -eq "Branch1" } | Add-ADPrincipalGroupMembership -MemberOf "CN=AccountLeads,OU=AccountDeptOU,DC=AppNC"

#Get-ADUser -SearchBase "OU=Demo,OU=Users, OU=Z-Users, DC=ad,DC=axs,DC=com" -Filter * | Add-ADgroupMember -Members "CN=Demo-sg, OU=Demo,OU=Users, OU=Z-Users, DC=ad,DC=axs,DC=com"

#Finish