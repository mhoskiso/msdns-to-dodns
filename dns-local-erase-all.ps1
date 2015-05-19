$domains = Get-WMIObject -Namespace 'Root\MicrosoftDNS' MicrosoftDNS_Domain | ? { $_.ContainerName -Notlike '..RootHints' -And $_.ContainerName -NotLike '..Cache' -And !$_.Reverse  -And $_.ContainerName -NotLike '*.arpa' -And $_.ContainerName -NotLike 'TrustAnchors'} | Select Name
$ErrorLog = "c:\tools\local-erase-errors.txt"


ForEach ($domain in $domains){
	try
	{
		write-host "Deleting all records for" $domain.Name
		$delcmd = "dnscmd /zonedelete " + $domain.Name + " -f"
		Invoke-Expression $delcmd
	}
	
	catch
	{
		"ERROR erasing Domain $domain.DomainName 	$_" | Add-Content $ErrorLog
	}

}