#Written by Trent Greeman
#This script takes an excel file of exported users and will assign and remove the 
#specified licenses from every user on the excel sheet. On the sheet, you must
#add two columns ('Add Licenses' and 'Remove Licenses') and the script will add
#all of the licenses in the 'Add Licenses' column and remove all licenses in the
#'Remove Licenses' column

Install-Module PSExcel
Import-Module psexcel
Import-Module MSOnline
Get-Command -Module psexcel

Connect-MsolService

#Gives license names for the tennant
$Availability = Get-MsolAccountSku | Select AccountSkuId,ActiveUnits,ConsumedUnits

#Users path
#$path = "C:/Users/Admin/Downloads/LASSD MS365 E3 users_8_5_2020 11_31_45 PM.xlsx"
$path = "C:/Users/Admin/Downloads/users_8_7_2020 9_01_50 PM.xlsx"

$content = Import-XLSX -Path $path -RowStart 1

foreach ($user in $content.'User principal name')
{
write-host $user
Set-MsolUser -UserPrincipalName $user -UsageLocation "US"

foreach ($AL in $content.'Add Licenses')
{#Add License to $user
if ($AL -ne $null)
{
write-host "Adding $AL to $user"
Set-MsolUserLicense -UserPrincipalName $user -AddLicenses $AL
}
}
foreach ($RL in $content.'Remove Licenses')
{#Remove License from $user
if ($RL -ne $null)
{
write-host "Removing $RL from $user"
Set-MsolUserLicense -UserPrincipalName $user -RemoveLicenses $RL
}
}
}

Get-MsolAccountSku | Select AccountSkuId,ActiveUnits,ConsumedUnits