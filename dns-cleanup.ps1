# Get valid domains. Ignore Rootservers, Cache, reverse records, .local domains, tcp,tls,domainkey records
$domains = Get-WMIObject -Namespace 'Root\MicrosoftDNS' MicrosoftDNS_Domain | ? { $_.ContainerName -Notlike '..RootHints' -And $_.ContainerName -NotLike '..Cache' -And !$_.Reverse -And $_.ContainerName -NotLike '*.local' -And $_.ContainerName -NotLike '*.arpa' -And $_.Name -NotLike '_domainkey*' -And $_.Name -NotLike '_tls*' -And $_.Name -NotLike '_tcp*' -And $_.ContainerName -NotLike 'TrustAnchors'} | Select Name

$ErrorLog = "c:\tools\cleanup-errors.txt"

# Check which domains are in DNS but aren't using our nameservers. Could be expired domains, terminated clients, or client hosted DNS.
ForEach ($domain in $domains)
{
	$addresses=(Resolve-DnsName -Name $domain.Name -Type NS -ErrorAction SilentlyContinue).IpAddress
	if ($addresses -NotContains '<add your NS1 IP>' -Or $addresses -NotContains '<Add your NS2 IP')
	{
		write-host "We don't host DNS for" $domain.Name | Export-Csv -NoTypeInformation c:\tools\cleanup.csv -Append
		
		ForEach ($address in $addresses)
		{
					write-host "nameserver ip: " $address 
		
		}
	$domain | Export-Csv -NoTypeInformation c:\tools\cleanup.csv -Append
	#Export a backup of the zones that will be cleaned
	$bakcmd = "dnscmd /zoneexport " + $domain.Name + " ..\..\..\tools\cleaned-zones\" + $domain.Name + ".dns.bak"
	$delcmd = "dnscmd /zonedelete " + $domain.Name + " -f"	
	
	try{
	write-host "Exporting a copy of" $domain.Name
	$error = (Invoke-Expression $bakcmd) 2>&1
	if ($lastexitcode) {throw $er}
	write-host "Deleting zone from server" $domain.Name
	Invoke-Expression $delcmd
	if ($lastexitcode) {throw $er}
	}
	catch
	{
	Add-Content $ErrorLog "$Domain.Name $_"
	}
	
	
	}
	
}




