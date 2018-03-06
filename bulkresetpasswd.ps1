#Set-OSCADAccountPassword -path "C:\Server_PS_Scripts\users\UserList.csv"

##################################################################################################################
# Please Configure the following variables....
$smtpServer="smtp.office365.com"
$userid='sysadm@axs.com'
$pwd= get-content C:\Server_PS_Scripts\credentials\cred1.txt | convertto-securestring
$creds = New-Object System.Management.Automation.PSCredential($userid,$pwd)
$from = "System Administrator <sysadm@axs.com>"
$csvfile = "C:\Server_PS_Scripts\users\LA_ADUsers_Export_ve.csv"
$urlrp = "https://auth.ad.axs.com"
$image1 = "C:\Server_PS_Scripts\logs\image001.png"
##################################################################################################################

$users = import-csv -Path $csvfile | select *
foreach($user in $users)
{
   $DisplayName = $user.'DisplayName'
   $samid       = $user.'user'
   $email       = $user.'email' 

    # Email Subject Set Here
    $subject="PASSWORD RESET NOTIFICATION"
  
    # Email Body Set Here, Note You can use HTML, including Images.
    $body ="
    <p>Dear $DisplayName,</p>
   
    <p>AXS IT is rolling out a new secure WI-FI solution. You will be issued your own unique Active Directory credentials in order to login. Please change your password immediately when you receive this email.</p>
    <p><strong>Username: $samid</strong></p>
    <p><strong>Password: P@ssw0rd1!</strong></p>
    <p>To change your password:</p>
   
    <p>1. Visit:&nbsp;<a href=$urlrp>https://auth.ad.axs.com</a></p>
    <p>2. Enter your username followed by @ad.axs.com. (ex.&nbsp;<a href="""">jsmith@ad.axs.com</a>)</p>
    <p>3. Type your current password<br />
    <p>4. Choose your new password and re-type to confirm.<br />
    <p>5. Hit ""Change Password"" to submit your new password.<br/><br/>
    
    You must change your password every 90 days. As always, please keep your password secret at all times.</p>
    <p<strong>>If you have any questions or issues, please contact IT</strong>.</p>
    
    </P>"

    # Send Email Message
    Send-Mailmessage -smtpServer $smtpServer -credential $creds -from $from -to $email -subject $subject -body $body -bodyasHTML -usessl -port 587 -priority High

    Write-Host "Notificacion enviada a" $DisplayName

    } 
# End Send Message