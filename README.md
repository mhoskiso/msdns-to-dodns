# msdns-to-dodns
Migration scripts to move Windows DNS to Digital Ocean DNS

The scripts included were used to help migrate from a DNS server on Windows 2008r2 to Digital Ocean DNS. Windows Server 2012 is required for the Digital Ocean Powershell module, but there are scripts to help import zone files from a 2008r2 server into 2012.
They probably aren't the most efficient or handle all possible errors, I just tweaked them until they worked for our situation. Be sure to do a few test runs first and check the output/logs for errors, then use the script to erase Digital Ocean DNS test runs before the final migration. The scripts are intended for a 1 time migration, You can't run these scripts multiple times or you will create duplicate entries on Digital Ocean.
Due to the number of DNS entries we had, I had to split up the scripts by DNS record type to avoid reaching the DigitalOcean API rate limit. Below you will find a description of each script sorted by the order you should run them in.

Requires the Digital Ocean Powershell module by KirkMunro
https://github.com/KirkMunro/DoPx
Run the following command in Powershell to verify module is installed:
Get-Command -Module DoPx


# zone-import.ps1

You can skip this if you're already hosting DNS on a Server 2012/r2 machine.
1. Open up DNS manager on your pre-2012 server, right click on forward lookup zones, select "Export list" and save dns-zones.csv.
2. Right click your dns server and select "Update Server Data Files"
3. Copy the zone files out of %SystemRoot%\System32\DNS\ into c:\tools\dns on the 2012 machine and dns-zones.csv into c:\tools

# dns-cleanup.ps1

OPTIONAL - We had a lot of old domains that needed to be cleaned up. This script does a nameserver lookup on all DNS zones and checks if they are still pointing to your current nameservers.
If a zone isn't using your dns server, a backup is exported and the zone is deleted from dns. Replace <ns1 ip address> & <ns2 ip address> with your current nameserver ip addresses.

# get-site-list.ps1

OPTIONAL - Used to get a list of websites being hosted in IIS

# nslookup-by-iis-sites.ps1

OPTIONAL - Used with get-site-list.ps1 to sites that aren't using your DNS server.

# dns-do-a.ps1

Copies your a records to Digital Ocean.

# dns-do-cname.ps1

Copies cname records to Digital Ocean.

# dns-do-mx.ps1

Copies mx records to Digital Ocean. If the domain is email only and wasn't added during the a record script, an error will be logged but the script will attempt to add the domain and mx record.

# dns-do-txt.ps1

Copies txt records to Digital Ocean.

# dns-do-srv.ps1

Copies srv records to Digital Ocean.

# dns-do-ns.ps1

Copies ns records to Digital Ocean. Only needed if you want vanity nameservers, Digital Ocean automatically adds ns(1-3).digitalocean.com

# dns-do-erase-all.ps1

WARNING! Erase all Digital Ocean DNS entries. Use during migration testing for a clean slate at Digital Ocean. Digital Ocean allows duplicate entries for some of these records so you'll have to run this to clear out your test runs before the actual migration.

# dns-local-erase-all.ps1

WARNING! This will delete all dns zones on your Windows server. If you are importing zones from a different server and take a while during the testing phase, you can run this and repeat the dns import process to get a fresh set of records when you are ready to migrate.

# dns-do-verify-import.ps1

Checks your DNS zone export list(minus cleaned up zones) to verify there is an entry at Digital Ocean after migration.