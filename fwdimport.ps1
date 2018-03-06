$var = import-csv C:\Server_PS_Scripts\credentials\list.csv

#Get-Content dddc02 | Foreach-Object {get-dnsserverforwarder -computer $_} | Export-csv -path C:\Server_PS_Scripts\credentials\dnsforwarderlist-output.csv


$var | foreach {
$cmd = "dnscmd /zoneadd $($_.zone) /forwarder $($_.servers)"
invoke-Expression $cmd
}