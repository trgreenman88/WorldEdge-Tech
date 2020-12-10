#Written by Trent Greenman
#This script will export a list of all teams with their Display Name, channels, owners,
#members, and visibility.  

$cred = Get-Credential
Import-Module MSOnline
Import-Module MicrosoftTeams
Connect-MsolService -Credential $cred
Connect-MicrosoftTeams -Credential $cred

$path = "C:\Teams.csv"

$headers = "DisplayName", "Visibility", "Channels", "Owners", "Members"
$psObject = New-Object psobject

foreach($header in $headers)
{
Add-Member -InputObject $psobject -MemberType noteproperty -Name $header -Value ""
}
$psObject | Export-Csv -Path $path -NoTypeInformation

$Teams = Get-Team

foreach ($i in $Teams)
{
$GroupID = $i.GroupId
$DisplayName = @($i.DisplayName)
$Visibility  = @($i.Visibility)
$Channels  = Get-TeamChannel -GroupId $GroupID
$Channels = $Channels.DisplayName
$Owners = Get-TeamUser -GroupId $GroupID -Role Owner
$Owners = $Owners.Name
$Members = Get-TeamUser -GroupId $GroupID -Role Member
$Members = $Members.Name


$listM = @()
foreach ($member in $Members)
{
$listM += $member
}
$listO = @()
foreach ($owner in $Owners)
{
$listO += $owner
}
$listC = @()
foreach ($channel in $Channels)
{
$listC += $channel
}


if ($listM.Length -ge $listC.Length -and $listM.Length -ge $listO.Length)
{
for ($i=0;$i-le $listM.Length;$i++)
{
$D = $DisplayName[$i]
$V = $Visibility[$i]
$M = $listM[$i]
$C = $listC[$i]
$O = $listO[$i]
$hash = @{
         "DisplayName" = $D
         "Visibility" = $V
         "Channels" = $C
         "Owners" = $O
         "Members" = $M
         }
$NewRow = New-Object PsObject -Property $hash
Export-Csv -Path $path -InputObject $NewRow -Append -Force
}
}

if ($listO.Length -gt $listC.Length -and $listO.Length -gt $listM.Length)
{
for ($i=0;$i-le $listO.Length;$i++)
{
$D = $DisplayName[$i]
$V = $Visibility[$i]
$M = $listM[$i]
$C = $listC[$i]
$O = $listO[$i]
$hash = @{
         "DisplayName" = $D
         "Visibility" = $V
         "Channels" = $C
         "Owners" = $O
         "Members" = $M
         }
$NewRow = New-Object PsObject -Property $hash
Export-Csv -Path $path -InputObject $NewRow -Append -Force
}
}


if ($listC.Length -gt $listM.Length -and $listC.Length -gt $listO.Length)
{
for ($i=0;$i-le $listC.Length;$i++)
{
$D = $DisplayName[$i]
$V = $Visibility[$i]
$M = $listM[$i]
$C = $listC[$i]
$O = $listO[$i]
$hash = @{
         "DisplayName" = $D
         "Visibility" = $v
         "Channels" = $C
         "Owners" = $O
         "Members" = $M
         }
$NewRow = New-Object PsObject -Property $hash
Export-Csv -Path $path -InputObject $NewRow -Append -Force
}
}

}