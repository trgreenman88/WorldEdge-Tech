#Written by Trent Greenman
#This script is designed to delete emails from the sent items folder and the deleted items folder from specified mailboxes.
#It is meant to clear mailboxes daily from the specified mailboxes. This does this by running a compliance search action
#(purge) until the folders are empty. Once they are empty, there will be an email notification sent out to the specified 
#email address.


######   AUTOMATION INSTRUCTIONS:   ######

#https://searchitchannel.techtarget.com/feature/Using-Windows-Powershell-scripts-for-task-automation

#1. Open the Task Scheduler:
#Control Panel--->System and Security--->Administrative Tools--->Schedule Tasks
#2. Select 'Create Task'
#3. Enter Task Name Ex:'Mail Deletion Automated Script'
#4. Select 'Run whether user is logged on or not'
#5. Select Change User Or Group to enter a user that has the proper VMM privileges to execute this PowerShell script.
#6. In the Triggers tab, enter the schedule you would like to create for this scheduled task.
#7. In the Actions tab, add a new action and select Start A Program. Click Browse and select the appropriate script.
#8. Click OK and enter the password for the account that will execute the scheduled task.
#9. From the Task Scheduler MMC, you can view all your scheduled tasks, check for their last run time, and see if 
#there were any errors in execution based on the last run result.


######   INPUT REQUIRED   ######
[string]$userName = 'admin@M365x654415.onmicrosoft.com'
[string]$userPassword = 'RcvsL1VB6R'
[SecureString]$secureString = $userPassword | ConvertTo-SecureString -AsPlainText -Force 
[PSCredential]$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $userName, $secureString


#####   INPUT REQUIRED   ######
$notifiedmailbox = "admin@M365x654415.onmicrosoft.com"
$mailbox1 = "admin@M365x654415.onmicrosoft.com"
$mailbox2 = "meganb@M365x654415.onmicrosoft.com"
$mailbox3 = "alexw@M365x654415.onmicrosoft.com"

$SccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.compliance.protection.outlook.com/powershell-liveid/" -Credential $credential -Authentication Basic -AllowRedirection
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication Basic -AllowRedirection

Import-PSSession $exchangeSession -DisableNameChecking -AllowClobber
Import-PSSession $SccSession -AllowClobber -DisableNameChecking

#####    ONLY NEED TO RUN THESE ONCE:    #####
#New-ManagementRoleAssignment -Role "Mailbox Search" -User "$userName"
#Add-eDiscoveryCaseAdmin "$userName"


#=======================================================================================================================



function GenerateFolderID($mailbox,$FolderName) 
    {
    $folderID = [Convert]::FromBase64String((Get-MailboxFolderStatistics $Mailbox | where {$_.Name -eq "$FolderName"}).folderID)

    $encoding = [System.Text.Encoding]::GetEncoding("us-ascii")
    $nibbler= $encoding.GetBytes("0123456789ABCDEF");

    $indexIdBytes = New-Object byte[] 48;$indexIdIdx=0;
    $folderID | select -skip 23 -First 24 | % { $indexIdBytes[$indexIdIdx++] = $nibbler[$_ -shr 4]; $indexIdBytes[$indexIdIdx++] = $nibbler[$_ -band 0xF]}
    return $encoding.GetString($indexIDBytes)
    }


#=======================================================================================================================
#Deletes Emails in the 'Sent Items' Folder and the 'Deleted Items' Folder

write-host 'Beginning search for Sent Items'

$FIDSent1 = GenerateFolderID -mailbox "$mailbox1" -FolderName "Sent Items"
$FIDSent2 = GenerateFolderID -mailbox "$mailbox2" -FolderName "Sent Items"
$FIDSent3 = GenerateFolderID -mailbox "$mailbox3" -FolderName "Sent Items"
$FIDDeleted1 = GenerateFolderID -mailbox "$mailbox1" -FolderName "Deleted Items"
$FIDDeleted2 = GenerateFolderID -mailbox "$mailbox2" -FolderName "Deleted Items"
$FIDDeleted3 = GenerateFolderID -mailbox "$mailbox3" -FolderName "Deleted Items"


New-ComplianceSearch -Name "DeleteMail" -ExchangeLocation "$mailbox1","$mailbox2","$mailbox3" -ContentMatchQuery "Folderid:$FIDSent1 OR Folderid:$FIDSent2 OR Folderid:$FIDSent3 OR Folderid:$FIDDeleted1 OR Folderid:$FIDDeleted2 OR Folderid:$FIDDeleted3"
Start-ComplianceSearch -Identity "DeleteMail"

$Status = Get-ComplianceSearch -Identity "DeleteMail"

write-host 'Searching for Sent Items and Deleted Items...'

while ($Status.status -ne "Completed")
{
$Status = Get-ComplianceSearch -Identity "DeleteMail"
}

Get-ComplianceSearch -Identity "DeleteMail" | FL name,items,size,jobprogress,status

#Deletes Sent Items
write-host 'Deleting Emails...'

while ($true)
{
New-ComplianceSearchAction -SearchName “DeleteMail” -purge -purgetype HardDelete -Force -Confirm:$false

$ActionStatus = Get-ComplianceSearchAction "DeleteMail_Purge"
while ($ActionStatus.Status -ne 'Completed')
{
$ActionStatus = Get-ComplianceSearchAction -Identity "DeleteMail_Purge"
}
write-host $ActionStatus
if ($ActionStatus.Results -eq 'Purge Type: HardDelete; Item count: 0; Total size 0; Details: {}')
{
break
}
}

write-host 'Printing results...'
Get-ComplianceSearchAction -Identity "DeleteMail_Purge" |Format-List -Property Results,status

write-host 'Sending results via email...'

######   INPUT REQUIRED   ######
$Subject = 'Automated Email Deletion'
$Body = Get-ComplianceSearchAction -Identity "DeleteMail_Purge" |Format-List -Property Results,status | Out-String
$To = "$notifiedmailbox"
$SMTP = "smtp.office365.com"
Send-MailMessage -To “$To” -From “$userName”  -Subject “$Subject” -Body “$Body” -Credential $credential -SmtpServer $SMTP -UseSsl -Port 587

#=======================================================================================================================

Remove-ComplianceSearch -Identity "DeleteMail" -Confirm:$false
Remove-PSSession $exchangeSession
Remove-PSSession $SccSession

