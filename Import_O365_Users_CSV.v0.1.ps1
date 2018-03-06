#Importing users with minimum user details using a CSV file

#This first command will import the Azure Active Directory module into your PowerShell session.
Import-Module MSOnline

#Capture administrative credential for future connections.
$userid='sysadm@axs.com'
$pwd= get-content C:\Users\Admin7\Documents\cred1.txt | convertto-securestring
$creds = New-Object System.Management.Automation.PSCredential($userid,$pwd)


#Establishes Online Services connection to Azure Active Directory  
Connect-MsolService -Credential $creds

#Creates an Exchange Online session
$ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $creds -Authentication Basic -AllowRedirection

#Import session commands
Import-PSSession $ExchangeSession 

#Export list of all distribution groups to CSV file at c:\reports\distribution_group.csv
Get-MsolUser -EnabledFilter EnabledOnly -MaxResults 200 | Export-Csv C:\Users\admin7\Downloads\Server_PS_Scripts\logs\msolusers.csv