Remove-item "$env:TEMP\Chromebook_OS_EOS.csv", "$env:TEMP\Chromebook_OS_EOS2.csv", "$env:TEMP\Chromebook_OS_EOS3.csv", "$env:TEMP\Chromebook_OS_EOS4.csv", "$env:TEMP\Chromebook_OS_EOS5.csv", "$env:TEMP\OUs.csv"
clear-host

# Use GAM to get a list of all district Chromebooks
gam print cros status assetid location model serialnumber autoUpdateExpiration lastSync osVersion orgUnitPath lastKnownNetwork MacAddress recentusers listlimit 1 | Out-File "$env:TEMP\Chromebook_OS_EOS.csv"

Import-Csv -Path "$env:TEMP\Chromebook_OS_EOS.csv" | Select-Object deviceId,status,annotatedAssetId,annotatedLocation,model,serialNumber,autoUpdateExpiration,lastSync,osVersion,orgUnitPath,macAddress,recentUsers.email,lastKnownNetwork.ipAddress,lastKnownNetwork.wanIpAddress | Export-Csv -Path "$env:TEMP\Chromebook_OS_EOS 1.csv" -NoTypeInformation

# Take the Chromebooks CSV and strip out headers I do not want and seperate Active, disabled and deprovisioned into separate CSV files
$CSVData = Import-Csv -Path "$env:TEMP\Chromebook_OS_EOS 1.csv" -Header deviceId,status,annotatedAssetId,annotatedLocation,model,serialNumber,autoUpdateExpiration,lastSync,osVersion,orgUnitPath,macAddress,recentUsers.email,lastKnownNetwork.ipAddress,lastKnownNetwork.wanIpAddress

$MatchingExportFile = "$env:TEMP\Chromebook_OS_EOS 3.csv"
$NonMatchingExportFile = "$env:TEMP\Chromebook_OS_EOS 2.csv"
$MatchingData = @()
$NonMatchingData = @()
$RegexStrings =  'DISABLED', 'DEPROVISIONED'

Foreach ($Row in $CSVData) {
    $MatchFound = $False
    Foreach ($TestString in $RegexStrings) {
        If ($Row.'status' -like $TestString) {
            $MatchFound = $True
            Break
        }
    }
    If ($MatchFound) {$MatchingData += $Row}
    Else {$NonMatchingData += $Row}
}

If ($MatchingData.Count -gt 0) {
    $MatchingData | Export-Csv -Path $MatchingExportFile -Force -NoTypeInformation
    Write-Host "Matching Data exported to $MatchingExportFile"
}
Else {Write-Host "No matching data to export!"}
If ($NonMatchingData.Count -gt 0) {
    $NonMatchingData | Export-Csv -Path $NonMatchingExportFile -Force -NoTypeInformation
    Write-Host "Non-matching Data exported to $NonMatchingExportFile"
}
Else {Write-Host "No non-matching data to export!"}

# Sort Active sheet by update expiration date and then by serial number
(Import-Csv "$env:TEMP\Chromebook_OS_EOS 2.csv") |
    Sort-Object autoUpdateExpiration, serialNumber |
    Export-Csv "$env:TEMP\Chromebook_OS_EOS 2.csv" -NoType


$CSVData = Import-Csv -Path "$env:TEMP\Chromebook_OS_EOS 3.csv" -Header deviceId,status,annotatedAssetId,annotatedLocation,model,serialNumber,autoUpdateExpiration,lastSync,osVersion,orgUnitPath,macAddress,recentUsers.email,lastKnownNetwork.ipAddress,lastKnownNetwork.wanIpAddress
$MatchingExportFile = "$env:TEMP\Chromebook_OS_EOS 4.csv"
$NonMatchingExportFile = "$env:TEMP\Chromebook_OS_EOS 5.csv"
$MatchingData = @()
$NonMatchingData = @()
$RegexStrings =  'DEPROVISIONED'

Foreach ($Row in $CSVData) {
    $MatchFound = $False
    Foreach ($TestString in $RegexStrings) {
        If ($Row.'status' -like $TestString) {
            $MatchFound = $True
            Break
        }
    }
    If ($MatchFound) {$MatchingData += $Row}
    Else {$NonMatchingData += $Row}
}

If ($MatchingData.Count -gt 0) {
    $MatchingData | Export-Csv -Path $MatchingExportFile -Force -NoTypeInformation
    Write-Host "Matching Data exported to $MatchingExportFile"
}
Else {Write-Host "No matching data to export!"}
If ($NonMatchingData.Count -gt 0) {
    $NonMatchingData | Export-Csv -Path $NonMatchingExportFile -Force -NoTypeInformation
    Write-Host "Non-matching Data exported to $NonMatchingExportFile"
}
Else {Write-Host "No non-matching data to export!"}

# Sort deprovisioned sheet by update expiration date and then by serial number
(Import-Csv "$env:TEMP\Chromebook_OS_EOS 4.csv") |
    Sort-Object autoUpdateExpiration, serialNumber |
    Export-Csv "$env:TEMP\Chromebook_OS_EOS 4.csv" -NoType

# Sort disabled sheet by update expiration date and then by serial number
(Import-Csv "$env:TEMP\Chromebook_OS_EOS 5.csv") |
    Sort-Object autoUpdateExpiration, serialNumber |
    Export-Csv "$env:TEMP\Chromebook_OS_EOS 5.csv" -NoType

#upload all sheets into one Google sheet, separate tabs.
gam user fsisd.gam@fsisd.net update drivefile <Drive File ID> newfilename "Chromebook OS EOS" localfile "$env:TEMP\Chromebook_OS_EOS 2.csv" csvsheet id:<Sheet / Tab ID>
gam user fsisd.gam@fsisd.net update drivefile <Drive File ID> newfilename "Chromebook OS EOS" localfile "$env:TEMP\Chromebook_OS_EOS 5.csv" csvsheet id:<Sheet / Tab ID>
gam user fsisd.gam@fsisd.net update drivefile <Drive File ID> newfilename "Chromebook OS EOS" localfile "$env:TEMP\Chromebook_OS_EOS 4.csv" csvsheet id:<Sheet / Tab ID>
