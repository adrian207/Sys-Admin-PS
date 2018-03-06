clear
#Capture administrative credential for future connections.
Set-ExecutionPolicy RemoteSigned
$userid='sysadm@axs.com'
$pwd= get-content C:\Server_PS_Scripts\credentials\cred01.txt | convertto-securestring
$creds = New-Object System.Management.Automation.PSCredential($userid,$pwd)

$global:session365 = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $creds -Authentication Basic -AllowRedirection

Import-PSSession $global:session365 -AllowClobber

Connect-MsolService -Credential $creds

$exportCSV = "C:\Server_PS_Scripts\users\users365.csv"
$importCSV = "C:\Server_PS_Scripts\users\Users-Updated.csv"


#Export Sort-Object from Office365 to CSV
get-user -resultsize unlimited -Sortby LastName | select FirstName,LastName, UserPrincipalName,Address,City,StateOrProvince, CountryOrRegion,Title,Department,Office,phoneNumber,Manager | Export-Csv $exportCSV 

#Get-MsolUser -All | Where-Object { $_.isLicensed -eq "TRUE" } | Select-Object FirstName,LastName, UserPrincipalName,Address,City,StateOrProvince, CountryOrRegion,Title,Department,Office,phoneNumber,Manager | Export-Csv $exportCSV 



#Import or Update From CSV to Office365       

#Import-Csv $importCSV | ForEach-Object {
 #           Set-User -FirstName $_.FirstName -LastName $_.LastName -Identity $_.Email -Streetaddress $_.Street -City $_.City -State $_.State -Country $_.Country -Title $_.JobTitle -Office $_.Office -Department $_.Department -Manager $_.Manager  }

 
Get-PSSession | Remove-PSSession