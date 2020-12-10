#Found online

<#
If you have the 2.0 general availability version of the Azure AD PowerShell module (AzureAD) installed,
you must uninstall it by running Uninstall-Module AzureAD in your PowerShell session, and then install 
the preview version by running Install-Module AzureADPreview.
#>

Uninstall-Module AzureAD
Install-Module AzureADPreview
Import-Module AzureADPreview

#INPUT REQUIRED
$GroupName = "Allow Teams Creation"

#All other groups will not be able to create teams.
$AllowGroupCreation = "False"

Connect-AzureAD

$settingsObjectID = (Get-AzureADDirectorySetting | Where-object -Property Displayname -Value "Group.Unified" -EQ).id
if(!$settingsObjectID)
{
    $template = Get-AzureADDirectorySettingTemplate | Where-object {$_.displayname -eq "group.unified"}
    $settingsCopy = $template.CreateDirectorySetting()
    New-AzureADDirectorySetting -DirectorySetting $settingsCopy
    $settingsObjectID = (Get-AzureADDirectorySetting | Where-object -Property Displayname -Value "Group.Unified" -EQ).id
}

#Restricts other groups from being able to create teams
$settingsCopy = Get-AzureADDirectorySetting -Id $settingsObjectID
$settingsCopy["EnableGroupCreation"] = $AllowGroupCreation

#Allows members of the specified group to create teams
if($GroupName)
{
    $settingsCopy["GroupCreationAllowedGroupId"] = (Get-AzureADGroup -Filter "DisplayName eq '$GroupName'").objectId
}
 else {
$settingsCopy["GroupCreationAllowedGroupId"] = $GroupName
}
Set-AzureADDirectorySetting -Id $settingsObjectID -DirectorySetting $settingsCopy

(Get-AzureADDirectorySetting -Id $settingsObjectID).Values

<#
If in the future you want to change which security group is used, you can rerun the script with the name of the new security group.

If you want to turn off the group creation restriction and again allow all users to create groups, set $GroupName to "" and 
$AllowGroupCreation to "True" and rerun the script.
#>