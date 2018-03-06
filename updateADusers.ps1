Import-Module ActiveDirectory

$USERS = Import-CSV C:\Server_PS_Scripts\users\demo.csv

$USERS|Foreach{

Set-ADUSer -Identity $_.samaccountname 
           -Title $_.JobTitle 
           -Description $_.Description 
           -StreetAddress $_.Street
           -Office $_.Office 
           -Deparment $_.Deparment
           -Manager $_.Manager
           
}
