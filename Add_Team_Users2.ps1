#This script adds a user to all marked teams from the script Export_Display_Names.ps1

$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop')
    Filter = 'SpreadSheet (*.csv)|*.csv' 
}
$null = $FileBrowser.ShowDialog()

$data = import-csv $FileBrowser.FileName

#loop through the users column
foreach ($User in $data)
{
$member = $User.User_Email

#stop if you have finished going throught all of the users
if ($member -eq "")
{
break
}

#nested loop through each team
foreach ($Team in $data)
{

if ($Team.Add -ne "")
{
$TeamName = Get-Team | where {$_.DisplayName -eq $Team.DisplayName}
$GroupId = $TeamName.GroupId
write-host "Adding $member to " $Team.DisplayName
Add-TeamUser -GroupId $GroupId -User $member
}

}

}