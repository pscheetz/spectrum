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

# Declare Variables
$logFile = "$PSScriptRoot\log.txt" # Saved to the same location as the .ps1 file
$iniFile = "$PSScriptRoot\ini-files\$version\Revit$version-$office-$department.ini" # The file MUST be in .ps1 root folder\ini-files\<year>!!
$date = Get-Date -Format "MM-dd-yyyy" # Used in the rename process if a revit ini exists already
$Users = (Get-ChildItem C:\Users).Name # Pulls all users from C:\Users and puts them in an array called $Users

function modifyFiles() {
    # Variables for the program data INI folder/file
    $programDataFolder = "C:\ProgramData\Autodesk\RVT $version\UserDataCache"
    $programDataFile = "C:\ProgramData\Autodesk\RVT $version\UserDataCache\Revit.ini"

    # Creates the folders necessary to copy the INI
    New-Item $programDataFolder -ItemType Directory -ErrorAction SilentlyContinue
    WriteLog "Created ProgramData Folder at $programDataFolder"

    # These two if statements remove the file if the code below it was already executed; it saves having to write a more complicated try-catch system and does the same thing
    if (Test-Path "$programDataFolder\Revit $date INI.old") {
            Remove-Item "$programDataFolder\Revit $date INI.old"
            WriteLog "Revit INI backup file from today exists already in ProgramData; deleting..."
    }

    # Renames the Revit INI file in ProgramData and in Appdata\Roaming if it exists (as a default Revit.ini file)
    if (Test-Path $programDataFile) {
            Rename-Item -Path $programDataFile -NewName "Revit $date INI.old"
            WriteLog "Saved pre-existing ProgramData Revit.ini as 'Revit $date INI.old'"
    } # end if

    try {
        Copy-Item $iniFile -Destination $programDataFile -ErrorAction Stop
        WriteLog "Copied new INI File to ProgramData"

    }
    catch [System.Management.Automation.ItemNotFoundException] { 
        WriteLog "CRITICAL ERROR: No INI file found for " + $version + " " + $whichOffice + " " + $whichDepartment + "."
        return # Breaks out of the foreach loop (like break but break doesn't work here)
    }

    # The below code applies to all users on the computer
    ForEach($User in $Users) {
        WriteLog "- Beginning iteration for user: $user -"
        # Creates the "Revit X Local" folder in the Documents folder on the user profile
        New-Item "C:\Users\$User\Documents\Revit $version Local" -ItemType Directory -ErrorAction SilentlyContinue
        WriteLog "Created Documents\Revit $version Local folder"

        # Variables for the folders
        $appDataFolder = "C:\Users\$User\AppData\Roaming\Autodesk\Revit\Autodesk Revit $version" 
        $appDataFile = "C:\Users\$User\AppData\Roaming\Autodesk\Revit\Autodesk Revit $version\Revit.ini" 

        New-Item $appDataFolder -ItemType Directory -ErrorAction SilentlyContinue
        WriteLog "Created AppData Folder at $appDataFolder"

        if (Test-Path "$appDataFolder\Revit $date INI.old") {
            Remove-Item "$appDataFolder\Revit $date INI.old"
            WriteLog "Revit INI backup file from today exists already in ProgramData; deleting..."

        }

        if (Test-Path $appDataFile) {
            Rename-Item -Path $appDataFile -NewName "Revit $date INI.old"
            WriteLog "Saved pre-existing AppData Revit.ini as 'Revit $date INI.old'"
        }
        
        #Copies the new INI file
        try {
            Copy-Item $iniFile -Destination $appDataFile -ErrorAction Stop
            WriteLog "Copied new INI File to AppData"

        }
        catch [System.Management.Automation.ItemNotFoundException] { 
            WriteLog "CRITICAL ERROR: No INI file found for " + $version + " " + $whichOffice + " " + $whichDepartment + "."
            return # Breaks out of the foreach loop (like break but break doesn't work here)
        }
        
        WriteLog "Script Completed!"

    } # Ends the ForEach Loop

} # end function

function WriteLog{
    Param ([string]$LogString)
    $TimeLog = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$TimeLog $LogString"
    Add-Content $logFile -value $LogMessage
} # end function

# Logs the beginning of the program, to know when it is run each time
WriteLog "`n`nStarting installation of Revit $version $office $department on $env:computername by $env:username"

modifyFiles