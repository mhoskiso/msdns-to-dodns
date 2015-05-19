$doAccessToken = ConvertTo-SecureString -AsPlainText -Force '<add your token>'
Set-DoPxDefaultAccessToken -AccessToken $doAccessToken

$ErrorLog = "c:\tools\sync-srv-errors.txt"

$srvrecords = Get-WMIObject -Namespace 'Root\MicrosoftDNS' MicrosoftDNS_SRVType | Select ContainerName, OwnerName, SRVDomainName, Priority, Port, Weight

ForEach ($srvrecord in $srvrecords)
{
	try{
		write-host "Domain:"  $srvrecord.ContainerName " Adding SRV record :" $srvrecord.OwnerName  " Pointing to: " $srvrecord.SRVDomainName " with Priority:"$srvrecord.Priority",Port:"$srvrecord.Port", Weight:"$srvrecord.Weight
		Add-DoPxDnsRecord -DomainName $srvrecord.ContainerName -SRV -ServiceName $srvrecord.OwnerName.TrimEnd($srvrecord.ContainerName) -HostName $srvrecord.SRVDomainName -Priority $srvrecord.Priority -Port $srvrecord.Port -Weight $srvrecord.Weight
	}
	catch 
	{
	 write-host "Domain: "$srvrecord.ContainerName "may not exist, attempting to create. Check the error log and verify entry added"
	 Add-DoPxDomain -Name $srvrecord.ContainerName -IPAddress 127.0.0.1
	 Add-DoPxDnsRecord -DomainName $srvrecord.ContainerName -SRV -ServiceName $srvrecord.OwnerName -HostName $srvrecord.SRVDomainName -Priority $srvrecord.Priority -Port $srvrecord.Port -Weight $srvrecord.Weight
	 "ERROR adding  $srvrecord.ContainerName  $srvrecord.OwnerName  	$_" | Add-Content $ErrorLog
	}
}