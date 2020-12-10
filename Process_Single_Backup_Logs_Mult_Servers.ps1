Install-Module PSExcel
Import-Module psexcel
#Gets a list of the server names
######   INPUT REQUIRED   ######
$excel = "C:/Users/Admin/Documents/Book1.xlsx"
$content = Import-XLSX -Path $excel -RowStart 1

#$ErrorActionPreference = "Stop"
$ErrorActionPreference = "Continue"

######   INPUT REQUIRED   ######
$To = "clientbackups@aegisinnovators.com"
$From = "backups@lassd.org"
$SMTP = "smtp.office365.com"
[string]$userName = 'ctirvine'
[string]$userPassword = 'ctirvine3901'
[SecureString]$secureString = $userPassword | ConvertTo-SecureString -AsPlainText -Force 
[PSCredential]$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $userName, $secureString


$Date = Get-Date
$Month = ($Date.Month).ToString()
$Day = ($Date.Day - 1).ToString()
$Year = ($Date.Year).ToString()
$Time = $Month + "_" + $Day + "_" + $Year

#Example Time Value:
#$Time = "7_21_2020"

$Day2 = ($Date.Day - 2).ToString()
$Time2 = $Month + "_" + $Day2 + "_" + $Year
#$Time2 = "7_20_2020"


foreach ($server in $content.'Server Names')
{

try
{
#$Path = "C:\Program Files\Microsoft Azure Recovery Services Agent\Temp\LastBackupFailedFiles17af1_$Time*.txt"
$Path = "\\$server\C:\Program Files\Microsoft Azure Recovery Services Agent\Temp\LastBackupFailedFiles*$Time*.txt"
$File = @(Get-Item -Path $Path)
$content1 = Get-Content -Path $File
}
catch
{
write-host "No failed backup file found for $Time on $server"
#Exits the program if there is no file found
#exit
}


try
{
#$Path2 = "C:\Program Files\Microsoft Azure Recovery Services Agent\Temp\LastBackupFailedFiles17af1_$Time2*.txt"
$Path2 = "\\$server\C:\Program Files\Microsoft Azure Recovery Services Agent\Temp\LastBackupFailedFiles*$Time2*.txt"
$File2 = @(Get-Item -Path $Path2)
$content2 = Get-Content -Path $File2
}
catch
{
write-host "No failed backup file found for $Time2 on $server"
#Exits the program if there is no file found
#exit
}



#Trivial lines at the beginning and end of each file
$trivial = "Consider adding these to exclusion list of backup policy.----------------------------------------------"
$trivial2 = "-------------------------------------------------------------------------------------------------------"

#Loops through each line of today's file
foreach ($line in $content1)
{

#Loops through each line of yesterday's file
foreach ($line2 in $content2)
{

write-host $line2
#Compares each line of today's file with each line of yesterday's file
if (($line2 -eq $line) -and ($line -ne $trivial) -and ($line -ne $trivial2) -and ($line -ne ""))
{
write-host 'Recurring Backup Failure Detected.'
write-host ""
write-host "File:" $line2
write-host ""
write-host "Sending Notification via email..."

$Subject1 = "Recurring Backup Failure ($CompName)"
$Body1 = "The following file has failed to backup more than once today. File Name: $line"
Send-MailMessage -To “$To” -From “$From” -Subject “$Subject1” -Body “$Body1” -Credential $credential -SmtpServer $SMTP -UseSsl -Port 25
}
}
}

}