########################### CREDENTIALS ###########################################################################
# Please Configure the following variables....
$smtpServer="smtp.office365.com"
$userid='sysadm@axs.com'
$pwd= get-content C:\Server_PS_Scripts\credentials\cred1.txt | convertto-securestring
$creds = New-Object System.Management.Automation.PSCredential($userid,$pwd)
###################################################################################################################

#$Body = Get-Content C:\Server_PS_Scripts\logs\pcemail.csv | Out-String
$csvfile = "C:\Server_PS_Scripts\logs\pcemailX.csv"


###################################################################################################################
$From = "System Administrator <sysadm@axs.com>"
$To = "pcisneros@axs.com"
#$Cc = "rngan@axs.com"
#$Attachment = "C:\Server_PS_Scripts\logs\pcemail.csv"
$Subject = "Passwd Reminder Report"

$users = import-csv -Path $csvfile | select *
foreach($user in $users)
{
   $date        = $user.'Date'
   $name        = $user.'name'
   $email       = $user.'EmailAddress'
   $expire      = $user.'DaystoExpire'
   $expireon    = $user.'ExpiresOn'
   $notify      = $user.'Notified'

  
    # Email Body Set Here, Note You can use HTML, including Images.
    $body ="
   
<table style= ""font-family: arial, sans-serif;border-collapse: collapse;width: 100%;"" >
  <tr style=""background-color: #f6f8f1;"" >
    <th style=""border: 1px solid #dddddd;text-align: left;padding: 8px;"">Date</th>
    <th style=""border: 1px solid #dddddd;text-align: left;padding: 8px;"">Name</th>
    <th style=""border: 1px solid #dddddd;text-align: left;padding: 8px;"">Email</th>
    <th style=""border: 1px solid #dddddd;text-align: left;padding: 8px;"">Days to Expire</th>
    <th style=""border: 1px solid #dddddd;text-align: left;padding: 8px;"">Expire On</th>
    <th style=""border: 1px solid #dddddd;text-align: left;padding: 8px;"">Was Notify?</th>
  </tr>

  =================== here ===========================
  <tr style=""background-color: #dddddd;"">
    <th style=""border: 1px solid #dddddd;text-align: left;padding: 8px;"">$date</td>
    <th style=""border: 1px solid #dddddd;text-align: left;padding: 8px;"">$name</td>
    <th style=""border: 1px solid #dddddd;text-align: left;padding: 8px;"">$email</td>
    <th style=""border: 1px solid #dddddd;text-align: left;padding: 8px;"">$expire</td>
    <th style=""border: 1px solid #dddddd;text-align: left;padding: 8px;"">$expireon</td>
    <th style=""border: 1px solid #dddddd;text-align: left;padding: 8px;"">$notify</td>
  </tr>

  ================== end ================================
</table>

        <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" background=""#000000"">
            <tr style=""background-color: #000000;""  >
                <td align=""center""><font color=""#f6f8f1"">If you have any questions or issues, please contact us</font><br/>
                    <a href=""mailto:itsupport@axs.com""><font color=""#f6f8f1"">IT Support</font></a>
                </td>
            </tr>
            <tr style=""background-color: #000000;"" >
                <td align=""center"" style=""padding: 20px 0 0 0;"">
                    <table border=""0"" cellspacing=""0"" cellpadding=""0"">
                        <tr>
                            <td width=""37"" style=""text-align: center; padding: 0 10px 0 10px;"">
                                <a href=""http://www.axs.com/"">
                                    <img src=""https://s6.postimg.org/5rumf9h1t/axs_blue_200.png"" width=""50"" height=""37"" alt=""AXS"" border=""0"" />
                                </a>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
   
    "

    # Send Email Message
    #Send-Mailmessage -smtpServer $smtpServer -credential $creds -from $from -to $email -subject $subject -body $body -bodyasHTML -usessl -port 587 -priority High

    Write-Host "Notificacion enviada a" $name

    } 
# End Send Message

#$Body = "
#"
$SMTPPort = "587"

#-Attachments $Attachment

Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -bodyasHTML -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $creds -priority High

#Remove-Item –path C:\Server_PS_Scripts\logs\pcemail.csv
#####################################################################################################################