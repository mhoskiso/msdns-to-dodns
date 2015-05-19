$doAccessToken = ConvertTo-SecureString -AsPlainText -Force '<add your token>'
Set-DoPxDefaultAccessToken -AccessToken $doAccessToken
$domains = Get-WMIObject -Namespace 'Root\MicrosoftDNS' MicrosoftDNS_Domain | ? { $_.ContainerName -Notlike '..RootHints' -And $_.ContainerName -NotLike '..Cache' -And !$_.Reverse -And $_.ContainerName -NotLike '*.local' -And $_.ContainerName -NotLike '*.arpa' -And $_.Name -NotLike '_domainkey*' -And $_.Name -NotLike '_tls*' -And $_.Name -NotLike '_tcp*' -And $_.ContainerName -NotLike 'TrustAnchors'} | Select Name
$ErrorLog = "c:\tools\sync-erase-errors.txt"


ForEach ($domain in $domains){
try{
write-host "Deleting all records for" $domain.Name
Remove-DoPxDomain -Name $domain.Name
}
catch{
"ERROR erasing Domain $domain.DomainName 	$_" | Add-Content $ErrorLog
}

}