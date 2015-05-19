$zones = Import-csv "C:\tools\dns-zones.csv" | Select Name

$ErrorLog = "c:\tools\import-errors.txt"

ForEach ($zone in $zones)
{
try{
$impcmd= "dnscmd /zoneadd " + $zone.Name + " /primary /load /file ..\..\..\tools\dns\" + $zone.Name + ".dns"
Invoke-Expression $impcmd
}
catch{
write-host "Error while importing " $zone.Name
Add-Content $ErrorLog "$zone.Name $_"
}
}


