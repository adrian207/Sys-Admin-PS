﻿##################################################################################################################
# Please Configure the following variables....
$smtpServer="smtp.office365.com"
$userid='sysadm@company.com'
$pwd= get-content C:\Server_PS_Scripts\cred\cred01.txt | convertto-securestring
$creds = New-Object System.Management.Automation.PSCredential($userid,$pwd)
$expireindays = 16
$from = "IT Support <itsupport@company.com>"
$logging = "Enabled" # Set to Disabled to Disable Logging
$logFile = "C:\Server_PS_Scripts\logs\pcemail.csv"
$testing = "Disabled" # Set to Disabled to Email Users
$testRecipient = "pcisneros@company.com"
#
$link = "https://auth.ad.company.com"
$logo = "https://s6.postimg.org/5rumf9h1t/axs_blue_200.png"
$panelX = "https://s6.postimg.org/ja1irjt75/panel_X.png"
$centerB = "text-align:center;color:grey;"
$centerT = "text-align:center;"
###################################################################################################################

# Check Logging Settings
if (($logging) -eq "Enabled")
{
    # Test Log File Path
    $logfilePath = (Test-Path $logFile)
    if (($logFilePath) -ne "True")
    {
        # Create CSV File and Headers
        New-Item $logfile -ItemType File
        Add-Content $logfile "Date,   Name,   EmailAddress,   DaystoExpire,   ExpiresOn,   Notified"
    }
} # End Logging Check

# System Settings
$textEncoding = [System.Text.Encoding]::UTF8
$date = Get-Date -format ddMMyyyy
# End System Settings

# Get Users From AD who are Enabled, Passwords Expire and are Not Currently Expired
Import-Module ActiveDirectory
$SearchBase = "OU=LA, OU=Users, OU=Z-Users, DC=ad, DC=company, DC=com"
$users = get-aduser -searchbase $SearchBase -filter * -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress |where {$_.Enabled -eq "True"} | where { $_.PasswordNeverExpires -eq $false } | where { $_.passwordexpired -eq $false }
$DefaultmaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

# Process Each User for Password Expiry
foreach ($user in $users)
{
    $Name = $user.Name
    $emailaddress = $user.emailaddress
    $passwordSetDate = $user.PasswordLastSet
    $PasswordPol = (Get-AduserResultantPasswordPolicy $user)
    $sent = "" # Reset Sent Flag
    # Check for Fine Grained Password
    if (($PasswordPol) -ne $null)
    {
        $maxPasswordAge = ($PasswordPol).MaxPasswordAge
    }
    else
    {
        # No FGP set to Domain Default
        $maxPasswordAge = $DefaultmaxPasswordAge
    }

  
    $expireson = $passwordsetdate + $maxPasswordAge
    $today = (get-date)
    $daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days
        
    # Set Greeting based on Number of Days to Expiry.

    # Check Number of Days to Expiry
    $messageDays = $daystoexpire

    if (($messageDays) -gt "1")
    {
        $messageDays = "in " + "$daystoexpire" + " days."
    }
    else
    {
        $messageDays = "today."
    }

    # Email Subject Set Here
    $subject="Your password will expire $messageDays"
  
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
                                <p style=""$centerT""><a href=""$link"">https://auth.ad.company.com</a></p>
                                <h3 style=""text-align:left;color:black;"">To change your password, proceed as follows:</h3>
                                <ol>
                                    <li>Enter your username followed by @ad.company.com. (ex. jsmith@ad.company.com)</li>
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
                                <a href=""http://www.company.com/"">
                                    <img src=""https://s6.postimg.org/5rumf9h1t/axs_blue_200.png"" width=""80"" height=""37"" alt=""AXS"" border=""0"" />
                                </a>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>

        "

   
    # If Testing Is Enabled - Email Administrator
    if (($testing) -eq "Enabled")
    {
        $emailaddress = $testRecipient
    } # End Testing

    # If a user has no email address listed
    if (($emailaddress) -eq $null)
    {
        $emailaddress = $testRecipient    
    }# End No Valid Email

    # Send Email Message
    if (($daystoexpire -ge "0") -and ($daystoexpire -lt $expireindays))
    {
        $sent = "Yes"
        # If Logging is Enabled Log Details
        if (($logging) -eq "Enabled")
        {   
          Add-Content $logfile "$date,$Name,$emailaddress,$daystoExpire,$expireson,$sent"  
        }
        # Send Email Message
        Send-Mailmessage -smtpServer $smtpServer -credential $creds -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -usessl -port 587 -priority High -Encoding $textEncoding 
        #Write-Host "Notificacion enviada a" $emailaddress

    } # End Send Message
    #else # Log Non Expiring Password
    #{
    #    $sent = "No"
    #    # If Logging is Enabled Log Details
    #    if (($logging) -eq "Enabled")
    #    {
    #        Add-Content $logfile "$date,$Name,$emailaddress,$daystoExpire,$expireson,$sent" 
    #    }        
    #}
    
}
# End
