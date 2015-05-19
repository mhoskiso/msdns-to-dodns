$doAccessToken = ConvertTo-SecureString -AsPlainText -Force '<add your token>'
Set-DoPxDefaultAccessToken -AccessToken $doAccessToken

$ErrorLog = "c:\tools\sync-cname-errors.txt"

$cnamerecords = Get-WMIObject -Namespace 'Root\MicrosoftDNS' MicrosoftDNS_CNAMEType | Select DomainName, OwnerName, RecordData

ForEach ($cnamerecord in $cnamerecords)
{

	try{
		write-host "Adding Cname:"  $cnamerecord.OwnerName "pointing to :" $cnamerecord.RecordData
		Add-DoPxDnsRecord -DomainName $cnamerecord.DomainName -CNAME -AliasName ($cnamerecord.OwnerName).Split('.')[0] -HostName $cnamerecord.RecordData
	}
	catch 
	{
	 write-host "Domain: "$cname.DomainName "may not exist, attempting to create. Check the error log and verify entry added"
	 Add-DoPxDomain -Name $cnamerecord.DomainName -IPAddress 127.0.0.1
	Add-DoPxDnsRecord -DomainName $cnamerecord.DomainName -CNAME -AliasName ($cnamerecord.OwnerName).Split('.')[0] -HostName $cnamerecord.RecordData
	"ERROR adding CNAME  $cnamerecord.RecordData 	$_" | Add-Content $ErrorLog
	}

}