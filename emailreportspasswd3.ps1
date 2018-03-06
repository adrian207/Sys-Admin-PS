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
$From = "System Administrator <itsupport@axs.com>"
$To = "pcisneros@axs.com"
#$Cc = "rngan@axs.com"
#$Attachment = "C:\Server_PS_Scripts\logs\pcemail.csv"

$Style = "<style type='text/css'>
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

 </style>"

$Subject = "Passwd Reminder Report"

import-csv $csvfile | ConvertTo-Html -Head $Style  | Out-File C:\Server_PS_Scripts\logs\out.htm

$Body = get-content -RAW -path C:\Server_PS_Scripts\logs\out.htm

$SMTPPort = "587"

#-Attachments $Attachment

Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -bodyasHTML -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $creds -priority High

Remove-Item –path C:\Server_PS_Scripts\logs\out.htm
#Remove-Item –path C:\Server_PS_Scripts\logs\pcemail.csv
#####################################################################################################################