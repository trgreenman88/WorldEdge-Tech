#Import-Module psexcel

#Gets a list of Event ID's and Sources
######   INPUT REQUIRED   ######
#$path = "C:/Azure Backup/EventSource.csv"
#$path2 = "C:/Azure Backup/EventID.csv"
$path = "C:/Users/Admin/Documents/Powershell Tests/EventSource.csv"
$path2 = "C:/Users/Admin/Documents/Powershell Tests/EventID.csv"
$serverslist2 = Import-Csv -Path $path
$IDlist = Import-Csv -Path $path2

#####   INPUT REQUIRED   ######
$notifiedmailbox = "clientbackups@aegisinnovators.com"

#$notifiedmailbox = "admin@M365x654415.onmicrosoft.com"
[string]$userName = 'ctirvine'
[string]$userPassword = 'ctirvine3901'
[SecureString]$secureString = $userPassword | ConvertTo-SecureString -AsPlainText -Force 
[PSCredential]$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $userName, $secureString

#Gets the date
$Date = Get-Date
$Month = ($Date.Month).ToString()
$Day = ($Date.Day - 1).ToString()
$Year = ($Date.Year).ToString()
$Time = $Month + "/" + $Day + "/" + $Year



foreach($i in $serverslist2)
{

$server = $i.'Server Names'
$source = $i.'Source'
write-host $server " " $source


#####     INPUT REQUIRED    #####
#$B = get-winevent -LogName "CloudBackup" -ComputerName $server 
$B = get-winevent -LogName "Setup"


#Loops through EventID.csv
foreach ($k in $IDlist)
{
$event = $k.'Event ID'

#Loops through each item in the event viewer
foreach ($j in $B)
{

if ($j.TimeCreated.ToString() -like "$Time*" -and $j.ID.ToString() -like $event -and $j.LevelDisplayName.ToString() -like $source)
{
write-host $j.TimeCreated " " $j.ID.ToString() " " $j.LevelDisplayName.ToString()

#Creates CSV File for results
#####   INPUT REQUIRED   #####
$path3 = "C:\Users/Admin/Documents/Powershell Tests/Results$Month.$Day.$Year.csv"

#Add the event to the csv file
$line = @([pscustomobject]@{
DateTime = $j.TimeCreated;
ServerName = $server;
EventID = $event;
Message = $j.Message
})
$line | Export-Csv -Path $path3 -Append -Force -NoTypeInformation
}

}

}

}


$Subject = "Backup Overview"
$Body = "Here is a file of all the backups that started." 
$To = "$notifiedmailbox"
$From = "alerts@aegisinnovators.com"
$SMTP = "relay.dnsexit.com"
#Send-MailMessage -To “$To” -From “$From”  -Subject “$Subject” -Body “$Body” -Attachments $path3 -Credential $credential -SmtpServer $SMTP -UseSsl -Port 80
Send-MailMessage -To “$To” -From “$From”  -Subject “$Subject” -Body “$Body” -Credential $credential -SmtpServer $SMTP -UseSsl -Port 80
write-host "EMAIL SENT"


