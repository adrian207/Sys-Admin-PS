Set-NetFirewallRule -Name "WINRM-HTTP-IN-TCP-PUBLIC" -RemoteAddress Any
netsh advfirewall firewall add rule Profile=public name="Allow WinRM HTTPS" dir=in localport=5986 protocol=TCP action=allow

Invoke-Command -ComputerName 172.18.0.36 -ScriptBlock {hostname} -Credential Admin7@ad.axs.com

winrm set winrm/config/client '@{AllowUnencrypted="True"}'

winrm set winrm/config/client/Auth '@{Basic="True"}'
