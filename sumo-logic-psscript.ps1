<#
.SYNOPSIS
Automatically checks configuration of remote systems, or automatically configures remote systems, for the Sumo Logic Remote Windows Event source.

.DESCRIPTION
sumo-remote-collector-config.ps1 checks remote systems' configuration, verifying that they can be targeted by the Sumo Logic Remote Windows Event source.

The following requirements are checked on each remote system
  - The account used for event collection has read access to event logs (administrator or in Event Log Readers group)
  - Firewall exceptions in the Remote Event Log Management group are enabled

If the -DoConfig parameter is used, required configuration is enabled remotely.

.PARAMETER ComputerName
An array of hostnames, IP addresses, or FQDNs of the remote systems which will be configured or checked

.PARAMETER File
Path to a text file containing the hostnames, IP addresses, or FQDNs of the remote systems which will be configured or checked.
One machine name per line.

.PARAMETER EventCollectionCredential
The credential that will be used for event collection. This should match the credential specified when configuring the source in Sumo Logic.

.PARAMETER AdminCredential
The credential used by this script to remotely access the target machines and make configuration changes. It need to have administrative access on the remote machines.

.PARAMETER DoConfig
If specified, configuration is updated (firewall exception added, user added to Event Log Readers group. Otherwise, configuration is only checked.

#>
[CmdletBinding(DefaultParameterSetName = 'cnlist')]
param(
    [Parameter(Mandatory = $false, ParameterSetName = 'cnlist')]
    [string[]] $ComputerName = @('localhost'),

    [Parameter(Mandatory = $true, ParameterSetName = 'cnfile')]
    [ValidateScript({Test-Path $_})]
    [string] $File,

    [Parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential] $EventCollectionCredential,

    [Parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential] $AdminCredential,

    [switch] $DoConfig
)

#requires -Version 2
Set-StrictMode -Version Latest

$computerNames =
    if($psCmdlet.ParameterSetName -eq 'cnlist'){ @(,$computername) }
    else { @(, @(Get-Content $file)) }

$userName = $EventCollectionCredential.UserName -replace '^\\',''

foreach($cn in $computerNames) {
    Write-Host $cn

    $sessionArg = @{}
    if($cn -ne 'localhost') {
        $sessionArg['Session'] =
            try { New-PsSession -ComputerName $cn -Credential $adminCredential -ea Stop }
            catch [Exception] {
                Write-Error $_
                $null
        }
    }

    if(($sessionArg['Session'] -ne $null) -or ($cn -eq 'localhost')){

        # do full configuration
        if($doConfig) {
            Write-Host "    Giving user read access to event logs " -nonew
            Invoke-Command @sessionArg -arg $userName -ScriptBlock {
                param($userName)

                function CanReadEvents($userName) {
                    $members = ((net localgroup 'Administrators') + (net localgroup 'Event Log Readers'))
                    ($members -contains $userName) -or ($members -contains ($userName -replace '^.+?\\',''))
                }

                $canReadEvents = CanReadEvents $userName
                $out = $null

                if(-not $canReadEvents) {
                    $out = net localgroup "Event Log Readers" $userName /add 2>&1
                    $canReadEvents = CanReadEvents $userName
                }

                if($canReadEvents){
                    Write-Host "OK" -Fore Green
                } else {
                    Write-Host "ERROR" -Fore Red
                    Write-Error "$out"
                }
            }

            Write-Host "    Enabling firewall exceptions for event log management " -nonew
            Invoke-Command @sessionArg -ScriptBlock {
                $out = netsh advfirewall firewall set rule group="Remote Event Log Management" new enable=yes 2>&1
                if($lastExitCode -eq 0) {
                    Write-Host "OK" -Fore Green
                } else {
                    Write-Host "ERROR" -Fore Red
                    Write-Error "$out"
                }
            }

        # just check for compliance
        } else {
            Write-Host "    User has read access to event logs? " -nonew
            Invoke-Command @sessionArg -arg $userName -ScriptBlock {
                param($userName)

                function CanReadEvents($userName) {
                    $members = ((net localgroup 'Administrators') + (net localgroup 'Event Log Readers'))
                    ($members -contains $userName) -or ($members -contains ($userName -replace '^.+?\\',''))
                }

                $canReadEvents = CanReadEvents $userName
                if($canReadEvents){ Write-Host "YES" -Fore Green }
                else { Write-Host "NO" -Fore Red }
            }

            Write-Host "    Firewall state: " -nonew
            Invoke-Command @sessionArg -ScriptBlock {
                'Domain','Public','Private' |%{
                    $profile = $_
                    netsh advfirewall show $profile state |%{
                        if($_ -match '^State\s+([^\s]+)$'){
                            $state = $matches[1]
                            Write-Host "$profile=$state " -nonew
                        }
                    }
                }
                Write-Host
            }

            Write-Host "    Firewall exceptions enabled for Remote Event Log Management?"
            Invoke-Command @sessionArg -ScriptBlock {
                function ShowRule($rule) {
                    Write-Host "      ${rule}: " -nonew
                    $enabled = $null
                    $ruleProfile = $null
                    netsh advfirewall firewall show rule $rule |%{
                        if($_ -match 'Enabled:\s+(.+)'){ $enabled = $matches[1] }
                        elseif ($_ -match 'Profiles:\s+(.+)'){
                            $ruleProfile = $matches[1]
                            $color = if($enabled -eq 'Yes'){ 'Green' } else { 'Red' }
                            Write-Host "$ruleProfile=$enabled " -nonew -fore $color
                        }
                    }
                    Write-Host
                }

                ShowRule "Remote Event Log Management (RPC)"
                ShowRule "Remote Event Log Management (NP-In)"
                ShowRule "Remote Event Log Management (RPC-EPMAP)"
            }
        }

        Write-Host "    Can get a test event as user '${userName}'? " -nonew
        $evt = wevtutil qe Application /c:1 /r:$cn /u:$userName "/p:$($EventCollectionCredential.GetNetworkCredential().Password)" 2>&1
        if($?){
            Write-Host "YES" -Fore Green
        } else {
            Write-Host "NO" -Fore Red
            Write-Error $evt
        }

        if($sessionArg['Session']){
            Remove-PsSession $sessionArg['Session']
        }
    }
}
