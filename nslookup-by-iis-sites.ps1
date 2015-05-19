$sites = Import-csv -path C:\tools\IIS_sites.csv
$log = "c:\tools\offsite-dns.txt" 

ForEach ($site in $sites)
{
	# Only check active sites with names that contain at least 1 period 
	if ($site.state -eq "Started" -And $site.Name.split(".").count -gt 1)
		{
			# Check if $site.Name is returning a subdomain
			if ($site.Name.split(".").count -gt 2)
			{
				$site.Name = $site.Name.split(".")
				$site.Name = $site.Name[$site.Name.count -2] + "." + $site.Name[$site.Name.count -1]
				$addresses=(Resolve-DnsName -Name $site.Name -Type NS -ErrorAction Stop)
			}
			else{
				$addresses=(Resolve-DnsName -Name $site.Name -Type NS -ErrorAction Stop)
			}
			
			if ($addresses.IpAddress -NotContains '<current NS1 ip>' -Or $addresses.IpAddress -NotContains '<current ns2 ip>')
			{
				write-host $site.name " DNS is hosted elsewhere. Alert Client before cutover. " 
				write-host $addresses.PrimaryServer
				$site.name | Out-File $log -append
				ForEach ($address in $addresses)
				{
					write-host "nameserver ip: " $address.IpAddress
		
				}
			}
		}
	else
		{
		$warning = $site.name + " is not running in IIS or doesn't contain a tld in the sitename. Skipping....."
		write-host $warning 
		$warning| Out-File $log -append
		}
}

