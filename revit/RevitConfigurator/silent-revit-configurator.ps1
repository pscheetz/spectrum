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
$date
$date = Get-Date -Format "MM-dd-yyyy" # Used in the rename process if a revit ini exists already


$Users = (Get-ChildItem C:\Users).Name


function modifyFiles() {
    $programDataFolder = "C:\ProgramData\Autodesk\RVT $version\UserDataCache"
    $programDataFile = "C:\ProgramData\Autodesk\RVT $version\UserDataCache\Revit.ini"

    # Creates the folders necessary to copy the INI
    Write-Host "Creating ProgramData Folder"
    New-Item $programDataFolder -ItemType Directory -ErrorAction SilentlyContinue

    # These two if statements remove the file if the code below it was already executed; it saves having to write a more complicated try-catch system and does the same thing
    if (Test-Path "$programDataFolder\Revit $date INI.old") {
            Remove-Item "$programDataFolder\Revit $date INI.old"
    }

    # Renames the Revit INI file in ProgramData and in Appdata\Roaming if it exists (as a default Revit.ini file)
    if (Test-Path $programDataFile) {
            Rename-Item -Path $programDataFile -NewName "Revit $date INI.old"
            Write-Host "Renamed old ProgramData INI File"
    } # end if

    try {
        Copy-Item $currentIniFile -Destination $programDataFile -ErrorAction Stop
        Write-Host "Copied INI File to ProgramData"

    }
    catch [System.Management.Automation.ItemNotFoundException] { 
        Write-Host "No INI file found for " + $version + " " + $whichOffice + " " + $whichDepartment + "."
        return # Breaks out of the foreach loop (like break but break doesn't work here)
    }

    # The below code applies to all users on the computer
    ForEach($User in $Users) {
        Write-Host "-------------------------------ITERATING FOR USER: $User-------------------------------"
        # Creates the "Revit X Local" folder in the Documents folder on the user profile
        Write-Host "Creating Documents Local folder"
        New-Item "C:\users\$User\Documents\Revit $version Local" -ItemType Directory -ErrorAction SilentlyContinue
        
        # Variables for the folders
        $appDataFolder = "C:\Users\$User\AppData\Roaming\Autodesk\Revit\Autodesk Revit $version" 
        $appDataFile = "C:\Users\$User\AppData\Roaming\Autodesk\Revit\Autodesk Revit $version\Revit.ini" 

        Write-Host "Creating AppData Folder"
        New-Item $appDataFolder -ItemType Directory -ErrorAction SilentlyContinue

        if (Test-Path "$appDataFolder\Revit $date INI.old") {
            Remove-Item "$appDataFolder\Revit $date INI.old"
        }

        if (Test-Path $appDataFile) {
            Rename-Item -Path $appDataFile -NewName "Revit $date INI.old"
            Write-Host "Renamed old AppData INI File"
        }
        
        #Copies the new INI file
        try {
            Copy-Item $currentIniFile -Destination $appDataFile -ErrorAction Stop
        }
        catch [System.Management.Automation.ItemNotFoundException] { 
            # Write-Host "No INI file found for " + $version + " " + $whichOffice + " " + $whichDepartment + "."
            return # Breaks out of the foreach loop (like break but break doesn't work here)
        }


    } # Ends the ForEach Loop

} # end function
modifyFiles