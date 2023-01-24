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
    [string]$department,

    [Parameter(HelpMessage="Enter if the script should install for a single user or everyone. Must be either 'all' or 'single'")]
    [ValidateSet('all','single')] # Must be in the department list here
    [string]$userInstallType = 'all'
)

# Declare Variables
$logFile = "C:\Temp\RevitConfigurator\revit-configurator-log.txt" # Saved to the same location as the .ps1 file
$iniFile = "C:\Temp\RevitConfigurator\ini-files\$version\Revit$version-$office-$department.ini" # The file MUST be in .ps1 root folder\ini-files\<year>!!
$date = Get-Date -Format "MM-dd-yyyy" # Used in the rename process if a revit ini exists already
$global:errors = 0
# Users is either the logged-on user, or everybody on the machine (at the time of run)
if ($userInstallType.Equals("single")) {
    $Users = $env:username
}
else {
    $Users = (Get-ChildItem C:\Users).Name # Pulls all users from C:\Users and puts them in an array called $Users
}

function modifyFiles() {
    WriteLogNoDate "Installing for users: $Users"
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
        WriteLog "CRITICAL ERROR: No INI file found for $version $office $department!"
        $global:errors = 1
        return # Breaks out of the foreach loop (like break but break doesn't work here)
    }

    # The below code applies to all users on the computer
    ForEach($User in $Users) {
        WriteLogNoDate "`nBeginning iteration for user: $user"
        # Creates the "Revit X Local" folder in the Documents folder on the user profile
        New-Item "C:\Users\$User\Documents\Revit $version Local" -ItemType Directory -ErrorAction SilentlyContinue
        WriteLog "Created Documents\Revit $version Local folder"

        # Variables for the folders
        $appDataFolder = "C:\Users\$User\AppData\Roaming\Autodesk\Revit\Autodesk Revit $version" 
        $appDataFile = "C:\Users\$User\AppData\Roaming\Autodesk\Revit\Autodesk Revit $version\Revit.ini" 

        New-Item $appDataFolder -ItemType Directory -ErrorAction SilentlyContinue
        WriteLog "Created AppData Folder at $appDataFolder"

        try {
            WriteLog "Checking if the Revit INI is already located in $appDataFolder"
            if (Test-Path "$appDataFolder\Revit $date INI.old" -ErrorAction Stop) {
                Remove-Item "$appDataFolder\Revit $date INI.old" -ErrorAction Stop
                WriteLog "Revit INI backup file from today exists already in AppData; deleting..."
            }
        }
        catch [System.UnauthorizedAccessException] {
            WriteLog "ERROR: No permission to modify $appDataFolder\Revit $date INI.old"
            $global:errors = 1
        }

        try {
            WriteLog "Trying to save the pre-existing AppData INI file"
            if (Test-Path $appDataFile -ErrorAction Stop) {
                Rename-Item -Path $appDataFile -NewName "Revit $date INI.old" -ErrorAction Stop
                WriteLog "Saved pre-existing AppData Revit.ini as 'Revit $date INI.old'"
            }
        }
        catch [System.UnauthorizedAccessException] {
            WriteLog "ERROR: No permission to modify $appDataFile"
            $global:errors = 1
        }
        
        #Copies the new INI file
        try {
            Copy-Item $iniFile -Destination $appDataFile -ErrorAction Stop
            WriteLog "Copied new INI File to AppData"

        }
        catch [System.Management.Automation.ItemNotFoundException] { 
            WriteLog "CRITICAL ERROR: No INI file found for $version $office $department!"
            $global:errors = 1
            return # Breaks out of the foreach loop (like break but break doesn't work here)
        }
        catch [System.UnauthorizedAccessException] {
            WriteLog "ERROR: No permission to copy the INI file to AppData."
            $global:errors = 1
        }

    } # Ends the ForEach Loop

} # end function

function WriteLog{
    Param ([string]$LogString)
    $TimeLog = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$TimeLog $LogString"
    Add-Content $logFile -value $LogMessage
    Write-Output $LogMessage
} # end function

function WriteLogNoDate{
    Param ([string]$LogString)
    $LogMessage = "$LogString"
    Add-Content $logFile -value $LogMessage
    Write-Output $LogMessage
} # end function


# Logs the beginning of the program, to know when it is run each time
WriteLogNoDate "`n`n`n--------------Starting installation of Revit $version $office $department on $env:computername by $env:username--------------"
modifyFiles
if ($errors -eq 1) {
    Write-Host "Completed, but with errors during installation. Check the log file for more information. Did you make sure you ran this as administrator?"
    WriteLog "Completed, but with errors during installation. Look above for more information!"
    exit 1
}
else {
    Write-Host "Installation completed successfully with no errors."
    WriteLog "Installation completed successfully with no errors."

}
