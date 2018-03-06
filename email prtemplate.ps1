##################################################################################################################
# Please Configure the following variables....
$smtpServer="smtp.office365.com"
$userid='sysadm@axs.com'
$pwd= get-content C:\Server_PS_Scripts\credentials\cred1.txt | convertto-securestring
$creds = New-Object System.Management.Automation.PSCredential($userid,$pwd)
$expireindays = 10
$from = "System Administrator <itsupport@axs.com>"
#$logging = "Enabled" # Set to Disabled to Disable Logging
#$logFile = "C:\Users\admin7\Downloads\Server_PS_Scripts\logs\pcemail.csv"
#$testing = "Enabled" # Set to Disabled to Email Users
$testRecipient = "pcisneros@axs.com"
#
$link = "https://auth.ad.axs.com"
$logo = "https://s6.postimg.org/5rumf9h1t/axs_blue_200.png"
$panelX = "https://s6.postimg.org/ja1irjt75/panel_X.png"
$centerB = "text-align:center;color:grey;"
$centerT = "text-align:center;"
$subject="Your password will expire $messageDays"
###################################################################################################################

 # Email Subject Set Here
  
    # Email Body Set Here, Note You can use HTML, including Images.
    $body ="
     <table width=""100%"" bgcolor=""#ffffff"" border=""0"" cellpadding=""0"" cellspacing=""0"">
            <tr>
                <td>
                    <table class=""content"" align=""center"" cellpadding=""0"" cellspacing=""0"" border=""0"">
                        <tr>
                            <td>
                                <h1 style=""$centerT""><img src=""$logo"" height=""100"" width=""300""></h1>
                                <h2 style=""$centerB"">Dear $name,</h2>
                                <h3 style=""$centerT"">Your AXS Active Directory password will be expiring $messageDays.</h3>
                                <p><h1 style=""$centerT""><img src=""$panelX"" height=""300"" width=""450""></h1></p>
                                <h3 style=""$centerB"">Please change your password by visiting</h3>
                                <p style=""$centerT""><a href=""$link"">https://auth.ad.axs.com</a></p>
                                <h3 style=""text-align:left;color:black;"">To change your password, proceed as follows:</h3>
                                <ol>
                                    <li>Enter your username followed by @ad.axs.com. (ex. jsmith@ad.axs.com)</li>
                                    <li>Type your current password</li>
                                    <li>Choose your new password and re-type to confirm.</li>
                                    <li>Hit ""Change Password"" to submit your new password.</li>
                                </ol>  

                                <p>You must change your password every 90 days.<br><br>
                                
                            </P></td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        
        <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" background=""#000000"">
            <tr style=""background-color: #f6f8f1;""  >
                <td align=""center""><font color=""#000000"">If you have any questions or issues, please contact us</font><br/>
                    <a href=""mailto:itsupport@axs.com""><font color=""#000000"">IT Support</font></a>
                </td>
            </tr>
            <tr style=""background-color: #f6f8f1;"" >
                <td align=""center"" style=""padding: 20px 0 0 0;"">
                    <table border=""0"" cellspacing=""0"" cellpadding=""0"">
                        <tr>
                            <td width=""37"" style=""text-align: center; padding: 0 10px 0 10px;"">
                                <a href=""http://www.axs.com/"">
                                    <img src=""https://s6.postimg.org/5rumf9h1t/axs_blue_200.png"" width=""80"" height=""37"" alt=""AXS"" border=""0"" />
                                </a>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>

        "
Send-Mailmessage -smtpServer $smtpServer -credential $creds -from $from -to $testRecipient -subject $subject -body $body -bodyasHTML -usessl -port 587 -priority High -Encoding $textEncoding   
