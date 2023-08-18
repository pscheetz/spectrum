# This updates properties of each user in a specified AD Group based on the provided CSV

# Path to the CSV file
$csvFilePath = ".\Everybody-users-Updated.csv"

# Read the CSV
$csvData = Import-Csv -Path $csvFilePath

#   CSV Property       Property in ldapDisplayName Format
$propertyToUpdate   = @{
    Department      = 'department'
    Title           = 'title'
    Company         = 'company'
    EmailAddress    = 'mail'
    OfficePhone     = 'telephoneNumber'
    MobilePhone     = 'mobile'
    Office          = 'physicalDeliveryOfficeName'
    StreetAddress   = 'streetAddress'
    City            = 'l'
    State           = 'st'
    Country         = 'c'
    Description     = 'description'
    Initials        = 'initials'
}

$properties = [string[]] $propertyToUpdate.Keys # For the properties in Get-ADUser - you can't set these as hash tables, must be arrays (string)

foreach ($csvRow in $csvData) {
    # Identify the user by SamAccountName or UserPrincipalName
    $identifier = $csvRow.SamAccountName # or $csvRow.UserPrincipalName

    $user = Get-ADUser -Filter { SamAccountName -eq $identifier } -Properties $properties

    foreach ($property in $propertyToUpdate.Keys) {

        $adProperty = $user.$property
        $csvProperty = $csvRow.$property

        # If the row is not blank AND If the existing property in AD does NOT match the CSV File
        if ($csvProperty -and $adProperty -eq $csvProperty) {

            # Set-ADUser -Identity $user -Replace @{$($propertyToUpdate[$property])=$csvProperty}
            Write-Output "Updated '$identifier' '$property' from '$($user.$property)' to '$($csvRow.$property)'"

        }
    }
}