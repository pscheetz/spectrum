# This retrieves properties of each user in a specified AD Group

# Replace "group" with the name of your group
$groupName = "Everybody"

# Get the group object
$group = Get-ADGroup $groupName

if ($group) {
    # Get members of the group
    $groupMembers = Get-ADGroupMember -Identity $group
    
    $userList = @()

    foreach ($member in $groupMembers) {
        # Check if the member is a user
        if ($member.objectClass -eq "user") {
    
            $user = Get-ADUser -Identity $member.SamAccountName -Properties SamAccountName,UserPrincipalName,Name,DisplayName,Department,Title,Company,EmailAddress,OfficePhone,MobilePhone,Fax,HomePhone,Office,StreetAddress,City,State,Country,Description,Enabled,GivenName,Initials,Surname,Manager,PasswordNeverExpires,CanonicalName
            
            if ($user) {
                # Add user information to the array
                $userList += $user
            }
        }
    }

    # Export user information to CSV
    $userList | Select-Object SamAccountName,UserPrincipalName, Name, DisplayName, Department, Title, Company, EmailAddress, OfficePhone, MobilePhone, Fax, HomePhone, Office, StreetAddress, City, State, Country, Description, Enabled, GivenName, Initials, Surname, Manager, PasswordNeverExpires, CanonicalName | Export-Csv -Path "$groupName-users.csv" -NoTypeInformation

} else {
    Write-Output "Group $groupName not found."
}
