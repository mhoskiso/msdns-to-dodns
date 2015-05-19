$doAccessToken = ConvertTo-SecureString -AsPlainText -Force '<add your token>'
Set-DoPxDefaultAccessToken -AccessToken $doAccessToken

$ErrorLog = "c:\tools\sync-mx-errors.txt"

$mxrecords = Get-WMIObject -Namespace 'Root\MicrosoftDNS' MicrosoftDNS_MXType | Select DomainName, MailExchange, Preference


ForEach ($mxrecord in $mxrecords)
{
	try{
		write-host "Adding MX Record for Domain:"  $mxrecord.DomainName "pointing to :" $mxrecord.MailExchange "with priority :" $mxrecord.Preference
		Add-DoPxDnsRecord -DomainName $mxrecord.DomainName -MX -HostName $mxrecord.MailExchange -Priority $mxrecord.Preference
	}
	catch{
	write-host "Domain: "$mxrecord.DomainName "may not exist, attempting to create. Check the error log and verify entry added"
	 Add-DoPxDomain -Name $mxrecord.DomainName -IPAddress 127.0.0.1
	Add-DoPxDnsRecord -DomainName $mxrecord.DomainName -MX -HostName $mxrecord.MailExchange -Priority $mxrecord.Preference
	"ERROR adding MX record  $mxrecord.MailExchange for $mxrecord.DomainName 	$_" | Add-Content $ErrorLog
	}
}