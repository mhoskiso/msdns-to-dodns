$doAccessToken = ConvertTo-SecureString -AsPlainText -Force '<add your token>'
Set-DoPxDefaultAccessToken -AccessToken $doAccessToken

$ErrorLog = "c:\tools\sync-a-errors.txt"

#Get valid A records. Ignore rootservers, cache, and arpa
$arecords = Get-WMIObject -Namespace 'Root\MicrosoftDNS' MicrosoftDNS_AType | ? { $_.ContainerName -Notlike '..RootHints' -And $_.ContainerName -NotLike '..Cache' -And !$_.Reverse -And $_.ContainerName -NotLike '*.arpa' -And $_.ContainerName -NotLike '*.local' } | Select DomainName, OwnerName, RecordData

ForEach ($arecord in $arecords)
{

if ($arecord.DomainName -eq $arecord.OwnerName){
 try{
 write-host "Adding Domain to Digital Ocean:" $arecord.DomainName
 Add-DoPxDomain -Name $arecord.DomainName -IPAddress $arecord.RecordData
 }
 catch{
	"ERROR adding Domain $arecord.DomainName 	$_" | Add-Content $ErrorLog
	}
 }
if ($arecord.DomainName -ne $arecord.OwnerName){
 try{
 write-host "Adding subdomain:"  ($arecord.OwnerName).Split('.')[0]
 Add-DoPxDnsRecord -DomainName $arecord.DomainName -A -HostName ($arecord.OwnerName).Split('.')[0] -IPv4Address $arecord.RecordData
 }
 catch{
    write-host "Tried to add A record for" $arecord.DomainName " but that domain might exist. Will attempt adding domain, check error log and verify entry successful"
	Add-DoPxDomain -Name $arecord.DomainName -IPAddress 127.0.0.1
	Add-DoPxDnsRecord -DomainName $arecord.DomainName -A -HostName ($arecord.OwnerName).Split('.')[0] -IPv4Address $arecord.RecordData
	"ERROR adding A record  $arecord.OwnerName 	$_" | Add-Content $ErrorLog
	}
 }


}