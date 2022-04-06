# Chrome-AUE-Inventory
Write Chromebook inventory with AUE to Google Sheet

This Powershell script will pull all of your Chromebook inventory from your Admin Console, separate them into three CSV files, Active, Disabled, and Deprovisioned
and then upload to your Google Sheet. For me, I have a separate tab with formulas that point back to the Sheet that was uploaded.
The biggest magic I think happens in column O where I have a formula that will attempt to get the geolocation of the WAN IP address at last checkin, and you can change
city to countryname or add a new column to show the country of the WAN IP address.
```
=IFERROR(importxml("http://api.geoiplookup.net/?query=" & N6, "//city"),)
=IFERROR(importxml("http://api.geoiplookup.net/?query=" & N6, "//countryname"),)
```

You can retrieve the geolocation immediately in the Powershell script instead of with the Google Sheet formula. In this code I also retrieve the latitude and longitude
of the location and then create a link to Google Maps pointing to general location of the login.
```
$apidata     = Invoke-RestMethod "http://api.geoiplookup.net/?query=$ip"
$city        = $apidata.ip.results.result.city
$countryname = $apidata.ip.results.result.countryname
$maplat      = $apidata.ip.results.result.latitude
$maplon      = $apidata.ip.results.result.longitude
$maploc      = "https://www.google.com/maps/@" + $maplat + "," + $maplon + ",13z"
```
Example of my Google Sheet with formulas.
https://docs.google.com/spreadsheets/d/1jsrWTIpRqWbe54hLfYhPQkojBCzHXrIPuw6IV0qVHG0/edit?usp=sharing
The "Active" tab is where GAM sends the data and the first tab is my dressed up one for examination.


Added list of Google OUs
Added list of staff groups
Added list of student groups
Added Chromebook battery health export

To get battery health export, changes must be made in Admin Console
The settings are located here:

Devices > Chrome > Settings > Devices > Device settings ~ User and device reporting

Report device hardware information
Navigate to Device settings.
In the organizational units list, select the OU to apply the setting to. This setting can be set at the Root or for specific OUs.
Scroll to the User and device reporting section.
For the Report device Hardware Information setting, select Enable all hardware information reporting.
Click Save.
Caution: It is possible to select Customize for the Report device Hardware Information setting. With that selected, you also need to check Power status and Storage status in the customized list.

Report device telemetry
Navigate to Device settings.
In the organizational units list, select the OU to apply the setting to. This setting can be set at the Root or for specific OUs.
Scroll to the User and device reporting section.
For the Report device telemetry setting, select Enable all telemetry reporting.
Click Save.
