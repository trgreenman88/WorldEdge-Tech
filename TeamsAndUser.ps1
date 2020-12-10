#Use $ErrorActionPreference = "Stop" to make error handling easier
$ErrorActionPreference = 'Stop'

Write-Host 'Hello! This script will allow you to do the following in Microsoft Teams:'
Write-Host 'Create a new team, add a channel to an existing team, add a user to an existing'
Write-Host 'team, or add a user to all of the teams that the host is in.'
Write-Host 'We search for teams using the team name and for users using their email'
Write-Host ''
Write-Host 'At any point, you can enter the letter "q" to quit the program'
Write-Host ''
try
{
Import-Module MicrosoftTeams
}

catch
{
Write-Error 'Please install MicrosoftTeams. This can be done by running the following command: Install-Module -Name MicrosoftTeams -Repository PSGallery -Force'
}

#Asks for username and password and runs until something valid is entered
while ($true)
{
try
{
write-output 'Please enter your credentials. You may enter "q" as your username to quit'
$cred = Get-Credential

#Run this to quit the program
if ($cred.UserName -eq 'q')
{
Write-Output 'You have quit the program'
break
}

Connect-MicrosoftTeams -Credential $cred
#This will break if the credentials are entered correctly
break
}

catch
{
Write-Warning 'The username or password entered was not found in the Employee Directory'
}
}

if ($cred.UserName -ne 'q')
{
Write-Output 'Which of the following would you like to do:'
write-Output '1. Create a new team'
Write-Output '2. Add a channel to an existing team'
Write-Output '3. Add a member to an existing team'
Write-Output '4. Create a new user'

#Gets input for which task you choose
$answer = Read-Host -Prompt 'Please enter 1, 2, 3, or 4. Enter anything else to quit'

#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
#Runs this to create a new team

if ($answer -eq '1')
{
write-host ''

#Visibility settings
write-output 'Would you like your team to be Public or Private?'
$Privacy = Read-Host -Prompt 'Enter "Public" or "Private". Anyting else will quit the program'
if ($Privacy -ne 'Public' -and $Privacy -ne 'Private')
{
write-output 'You have quit the program'
break
}

#Team name and description
$DisplayName = Read-Host -Prompt 'Please enter your Team Name'

#quits the program if the team name is q
if ($DisplayName -eq 'q')
{
write-output 'You have quit the program'
break
}

$Description = Read-Host -Prompt 'Please enter your Team Description'

#quits the program if the description is q
if ($Description -eq 'q')
{
write-output 'You have quit the program'
break
}

#Creates the team
New-Team -DisplayName $DisplayName -Description $Description -Visibility $Privacy
}

#----------------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------
#Runs this to create a new channel

elseif ($answer -eq '2')
{
while ($true)
{
try
{
write-host ''
#input for team name
$TeamName = Read-Host -Prompt 'Please enter the Team Name'

#quits the program if the team name is q
if ($TeamName -eq 'q')
{
Write-Output 'You have quit the program'
break
}

$Team = Get-Team | where {$_.DisplayName -eq $TeamName}
$GroupId = $Team.GroupId

#Handles errors with invalid team names
if ($GroupId -eq $null)
{
write-error 'Null Team Name'
}

#input for channel name
$ChannelName = Read-Host -Prompt 'Please enter the Channel Name'

#quits the program if the channel name is q
if ($ChannelName -eq 'q')
{
Write-Output 'You have quit the program'
break
}

$ChannelDescription = Read-Host -Prompt 'Please enter Channel Description'

#quits if channel description is q
if ($ChannelDescription -eq 'q')
{
Write-Output 'You have quit the program'
break
}

#creates a new channel
New-TeamChannel -GroupId $GroupId -DisplayName $ChannelName -Description $ChannelDescription
break
}

#handles error where someone enters an invalid team name
catch
{
Write-Warning 'The Team Name entered may be invalid, please try again.'
}
}
}

#----------------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------
#Runs this to add a user to team(s)

elseif ($answer -eq '3')
{
Write-Host ''
while ($true)
{
try
{

$User = Read-Host -Prompt 'Please enter user email'

#quits the program if username is q
if ($User -eq 'q')
{
Write-Output 'You have quit the program'
break
}

Write-Output ''
Write-Output 'Would you like to add the user to 1 team or all teams?'
$TeamQuantity = Read-Host -Prompt 'Please enter 1 for one team or 2 for all teams. Enter anything else to quit'


#Runs this to add a user to 1 team
if ($TeamQuantity -eq '1')
{
Write-Host ''
$TeamName = Read-Host -Prompt 'Please enter the Team Name you would like this user to be added to'

#quits if Team Name is q
if ($TeamName -eq 'q')
{
Write-Output 'You have quit the program'
break
}

$Team = Get-Team | where {$_.DisplayName -eq $TeamName}
$GroupId = $Team.GroupId
Add-TeamUser -GroupId $GroupId -User $User
break
}


#Runs this to add a user to all teams
elseif ($TeamQuantity -eq '2')
{
$Teams = Get-Team
foreach ($i in $Teams)
{
$GroupId = $i.GroupId
Add-TeamUser -GroupId $GroupId -User $User
break
}
}

#quits the program if 1 or 2 isn't entered for the $TeamQuantity variable
else
{
Write-Output 'You have quit the program'
break
}
}

#handles error with invalid username
catch [Microsoft.TeamsCmdlets.PowerShell.Custom.ErrorHandling.ApiException]
{
Write-Warning 'The email entered may be invalid, please try again.'
}

#handles error with invalid Team name and/or username
catch
{
Write-Warning 'The Team Name and/or email entered may be invalid, please try again.'
}
}
}

#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
#runs this to create a new user

elseif ($answer -eq 4)
{
write-output ''
try
{
Import-Module MSOnline
}
catch
{
Write-Error 'Please install MSOnline. This can be done by running the following command: Install-Module MSOnline'
}

#Add the user

Connect-MsolService -Credential $Office365credentials

while ($true)
{
try{
$DisplayName = Read-Host -Prompt 'Enter Display Name'

if ($DisplayName -eq 'q')
{
Write-Output 'You have quit the program'
break
}

$First = Read-Host -Prompt 'Enter First Name'

if ($First -eq 'q')
{
Write-Output 'You have quit the program'
break
}

$Last = Read-Host -Prompt 'Enter Last Name'

if ($Last -eq 'q')
{
Write-Output 'You have quit the program'
break
}

$email = Read-Host -Prompt 'Enter email'

if ($email -eq 'q')
{
Write-Output 'You have quit the program'
break
}

$country = Read-Host -Prompt 'Enter 2 letter country code'

if ($country -eq 'q')
{
Write-Output 'You have quit the program'
break
}

New-MsolUser -LicenseAssignment M365x654415:Win10_VDA_E3 -DisplayName $DisplayName -FirstName $First -LastName $Last -UserPrincipalName $email -UsageLocation $country
break
}

catch
{
Write-Warning 'Please make sure you entered a valid email address and country code.'
}
}

}

#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
#quits the program if you don't enter 1,2, or 3 for the $answer variable

else
{
Write-Output 'You have quit the program'
}

}