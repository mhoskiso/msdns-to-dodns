$doAccessToken = ConvertTo-SecureString -AsPlainText -Force '<add your token>'
Set-DoPxDefaultAccessToken -AccessToken $doAccessToken

$ErrorLog = "c:\tools\sync-ns-errors.txt"

$nsrecords = Get-WMIObject -Namespace 'Root\MicrosoftDNS' MicrosoftDNS_NSType | ? { $_.ContainerName -Notlike '..RootHints' -And $_.ContainerName -NotLike '..Cache' -And !$_.Reverse -And $_.ContainerName -NotLike '*.arpa' -And $_.ContainerName -NotLike 'TrustAnchors' -And $_.ContainerName -NotLike '*.local'} | Select DomainName,NSHost

ForEach ($nsrecord in $nsrecords)
{
	try{
		write-host "Domain:"  $nsrecord.DomainName " Adding NS record :" $nsrecord.NSHost  
		Add-DoPxDnsRecord -DomainName $nsrecord.DomainName -NS -NameServer $nsrecord.NSHost
	}
	catch{
	write-host "Domain: "$nsrecord.DomainName "may not exist, attempting to create. Check the error log and verify entry added"
	Add-DoPxDomain -Name $nsrecord.DomainName -IPAddress 127.0.0.1
	Add-DoPxDnsRecord -DomainName $nsrecord.DomainName -NS -NameServer $nsrecord.NSHost
	"ERROR adding  $nsrecord.DomainName  $nsrecord.NSHost  	$_" | Add-Content $ErrorLog
	}
}