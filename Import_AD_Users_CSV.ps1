$users = Import-Csv -Path C:\Server_PS_Scripts\users\demo.csv

foreach ($user in $users){
	if($u = Get-ADUser -Filter "sAMAccountName -eq '$($user.sAMAccountname)'"){ 
		$splat = @{
						Givenname = $user.FirstName
						Surname = $user.LastName
                        physicalDeliveryOfficeName = $user.Office
                        Office = $user.Office
                        Title = $user.JobTitle
						Description = $user.JobTitle
						Department = $user.Department
						Company = $user.Company
						PostalCode = $user.PostalCode
						City = $user.City
                        State = $user.State
                        Country = $user.Country
						StreetAddress = $user.Street
						#OfficePhone = $user.PhoneNumber
						#Fax = $user.facsimileTelephoneNumber
						EmailAddress = $user.Email
                        Manager = $user.Manager
						
        	}
		$u | Set-ADUser @splat
	}else{
		Write-Host "User not found $($user.sAMAccountname)"
	}
} 