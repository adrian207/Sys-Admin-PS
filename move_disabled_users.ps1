$moveToOU = "OU=Disabled, OU=Z-Users, DC=ad, DC=axs, DC=com"

Search-ADAccount -AccountDisabled -UsersOnly | Select Name,Distinguishedname | Out-GridView -OutputMode Multiple | foreach 
{ 
 
 Move-ADObject -Identity $_.DistinguishedName -TargetPath $moveToOU
 Write-Host "user moved"

}