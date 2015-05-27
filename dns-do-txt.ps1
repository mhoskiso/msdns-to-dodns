$doAccessToken = ConvertTo-SecureString -AsPlainText -Force '<add your token>'
Set-DoPxDefaultAccessToken -AccessToken $doAccessToken

$ErrorLog = "c:\tools\sync-txt-errors.txt"

$txtrecords = Get-WMIObject -Namespace 'Root\MicrosoftDNS' MicrosoftDNS_TXTType | Select ContainerName, OwnerName, RecordData



ForEach ($txtrecord in $txtrecords)
{
	if ($txtrecord.ContainerName -eq $txtrecord.OwnerName){
	$txtrecord.OwnerName = "@"
	
 }
 else{
 $txtrecord.OwnerName = $txtrecord.OwnerName.TrimEnd($txtrecord.ContainerName)
 }
	
	try	{
		
		write-host "Domain:"  $txtrecord.ContainerName " Adding TXT record :" $txtrecord.OwnerName  " Data: " $txtrecord.RecordData
		Add-DoPxDnsRecord -DomainName $txtrecord.ContainerName -TXT -RecordName $txtrecord.OwnerName -Message $txtrecord.RecordData
	}
catch{
	write-host "Domain: "$txtrecord.ContainerName "may not exist, attempting to create. Check the error log and verify entry added"
	Add-DoPxDomain -Name $txtrecord.ContainerName -IPAddress 127.0.0.1
	Add-DoPxDnsRecord -DomainName $txtrecord.ContainerName -TXT -RecordName $txtrecord.OwnerName -Message $txtrecord.RecordData
	
	"ERROR adding  $txtrecord.ContainerName  $txtrecord.OwnerName  	$_" | Add-Content $ErrorLog
	}
}