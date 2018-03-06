#Capture administrative credential for future connections.
$userid='sysadm@axs.com'
$pwd= get-content C:\Server_PS_Scripts\credentials\cred1.txt | convertto-securestring
$creds = New-Object System.Management.Automation.PSCredential($userid,$pwd)


Connect-MsolService -Credential $creds