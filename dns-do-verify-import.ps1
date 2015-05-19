$doAccessToken = ConvertTo-SecureString -AsPlainText -Force '<add your token>'
Set-DoPxDefaultAccessToken -AccessToken $doAccessToken
$zones = Import-csv "C:\tools\dns-zones.csv" | Select Name
$cleaned = Import-csv "C:\tools\cleanup.csv" | Select Name
$ErrorLog = "c:\tools\not-in-do.txt"

ForEach ($zone in $zones)
{
try{
	if($cleaned.Name -notcontains $zone.Name){
	Get-DoPxDomain -Name $zone.Name
	}
}
catch{
	"$zone.Name not on Digital Ocean	$_" | Add-Content $ErrorLog
}

}

