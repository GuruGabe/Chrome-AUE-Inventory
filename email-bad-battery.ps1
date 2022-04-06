$smtp = "smtp.gmail.com" # This is your SMTP Server
$to1 = "user1@domain.com" # This is the recipient smtp address 1
$to2 = "user2@domain.com" # This is the recipient smtp address 2
$to3 = "user3@domain.com" # This is the recipient smtp address 3
$to4 = "user4@domain.com" # This is the recipient smtp address 4
$to5 = "user5@domain.com" # This is the recipient smtp address 5
$to6 = "user6@domain.com" # This is the recipient smtp address 6

$smtpUsername = "smtp@domain.com"  
$smtpPassword = "password"  
$credentials = new-object Management.Automation.PSCredential $smtpUsername, ($smtpPassword | ConvertTo-SecureString -AsPlainText -Force)
$from = "<Alert@domain.com>" # This will be the sender's address
$subject = "Chromebooks with a bad battery"

$csv = import-csv "C:\Temp\bad-battery.csv"
$report = 
foreach($row in $csv){
#OU,AssetID,Location,Model,Serial,MAC,User,Battery
    [pscustomobject]@{
		"OU" = $row.OU
		"Asset ID" = $row.AssetID
		"Location" = $row.Location
		"Model" = $row.Model
		"Serial Number" = $row.Serial
        "MAC Address" = $row.MAC
	    "User" = $row.User
        "Battery Status" = $row.Battery

    }
}


$header = @"
<style>

    h1 {

        font-family: Arial, Helvetica, sans-serif;
        color: #e68a00;
        font-size: 28px;

    }

    
    h2 {

        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 16px;

    }

    
    
   table {
		font-size: 12px;
		border: 1px solid black;
		font-family: Arial, Helvetica, sans-serif;
	} 
	
    td {
		padding: 4px;
		margin: 0px;
		border: 1px solid black;
	}
	
    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
	}

    tbody tr:nth-child(even) {
        background: #d8d8d9;
    }

        #CreationDate {

        font-family: Arial, Helvetica, sans-serif;
        color: #ff3300;
        font-size: 12px;

    }
    



</style>
"@

$report | 
ConvertTo-Html -Head $header | 
Out-File C:\Temp\battery.html

$body1 = "<b>These Chromebooks are reporting to Google that they have bad batteries. Please check the batteries and replace as needed.</b>"
$body2 = "<br /><br />"
$body3 = Get-Content C:\Temp\battery.html | Out-String
$body = "$body1 $body2 $body3"

send-MailMessage -SmtpServer $smtp -Port 587 -UseSsl -Credential $credentials -To $to1, $to2, $to3, $to4, $to5, $to6 -From $from -Subject $subject -Body $body -BodyAsHtml -Priority high
#, $to2, $to3, $to4, $to5, $to6
