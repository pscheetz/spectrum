# Creates a parameter that either asks the user or can be passed in when the script is called.
param(
    [Parameter(Mandatory,HelpMessage="Enter the version!")]
    [ValidateRange(2017,9999)] # Makes sure it is a valid year between x and y
    [int]$version, # This requires the user to input some version

    [Parameter(Mandatory,HelpMessage="Enter the office. Must be either 'SLC' or 'Tempe'")]
    [ValidateSet('SLC','Tempe')] # Must be one of the offices in the list
    [string]$office,

    [Parameter(Mandatory,HelpMessage="Enter the department. Must be either 'Electrical' or 'Mechanical'")]
    [ValidateSet('Electrical','Mechanical')] # Must be in the department list here
    [string]$department 

)

$currentIniFile = "$PSScriptRoot\ini-files\$version\Revit$version-$office-$department.ini" # The file MUST be in .ps1 root folder\ini-files\<year>!!

Write-Host "Your path: `n$currentIniFile`n"