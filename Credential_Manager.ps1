#Written by Trent Greenman
#This script is designed to map drives to virtual machines so that clients can access their files.

#Gets credentials for new windows credential
$Cred = Get-Credential
$User = $Cred.UserName
$Password = $Cred.Password

#Adds new windows credential
cmdkey /add:smaserver /user:$User /pass:$Password

#Removes any mapped network drives
net use D: /delete
net use i: /delete
net use K: /delete
net use L: /delete
net use r: /delete
#net use s: /delete

#Maps each network drive
New-PSDrive -Name D -Credential $Cred -Scope Global -Persist -PSProvider FileSystem -Root "\\smaserver\studioma"
New-PSDrive -Name i -Credential $Cred -Scope Global -Persist -PSProvider FileSystem -Root "\\smaserver\_images"
New-PSDrive -Name k -Credential $Cred -Scope Global -Persist -PSProvider FileSystem -Root "\\smaserver\archive"
New-PSDrive -Name L -Credential $Cred -Scope Global -Persist -PSProvider FileSystem -Root "\\smaserver\library"
New-PSDrive -Name r -Credential $Cred -Scope Global -Persist -PSProvider FileSystem -Root "\\smaserver\obo"
#New-PSDrive -Name s -Credential $Cred -Scope Global -Persist -PSProvider FileSystem -Root "\\smaserver\scans"
