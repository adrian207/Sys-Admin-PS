########################### CREDENTIALS ###########################################################################
# Please Configure the following variables....
$smtpServer="smtp.office365.com"
$userid='sysadm@axs.com'
$pwd= get-content C:\Server_PS_Scripts\credentials\cred01.txt | convertto-securestring
$creds = New-Object System.Management.Automation.PSCredential($userid,$pwd)
###################################################################################################################

#$Body = Get-Content C:\Server_PS_Scripts\logs\pcemail.csv | Out-String
$csvfile = "C:\Server_PS_Scripts\logs\pcemail.csv"


###################################################################################################################
$From = "System Administrator <itsupport@axs.com>"
$To = "itsysadmin@axs.com"
#$Cc = "rngan@axs.com"

$Style = "<style type='text/css'>
html {
  height: 100%;
  box-sizing: border-box;
}

*,
*:before,
*:after {
  box-sizing: inherit;
}

body {
  position: relative;
  margin: 0;
  padding-bottom: 6rem;
  min-height: 100%;
  font-family: ""Helvetica Neue"", Arial, sans-serif;
}

 table {
    border-collapse: collapse;
    border-spacing: 0;
    width: 100%;
    border: 1px solid #ddd;
}

th, td {
    border: none;
    text-align: left;
    padding: 8px;
}

tr:nth-child(even){background-color: #f2f2f2}

.footer {
  position: absolute;
  right: 0;
  bottom: 0;
  left: 0;
  padding: 1rem;
  background-color: #efefef;
  text-align: center;
}

 </style>"

$Subject = "Password Reminder ||| AXS Daily Report"

import-csv $csvfile | ConvertTo-Html -Head $Style  | Out-File C:\Server_PS_Scripts\logs\out.htm

$Body = get-content -RAW -path C:\Server_PS_Scripts\logs\out.htm

$SMTPPort = "587"

#-Attachments $Attachment

Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -bodyasHTML -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $creds -priority High

Remove-Item –path C:\Server_PS_Scripts\logs\out.htm
Remove-Item –path C:\Server_PS_Scripts\logs\pcemail.csv
##############################################