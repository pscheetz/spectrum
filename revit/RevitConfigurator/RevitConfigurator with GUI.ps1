# Created by Philip Scheetz @ Spectrum Engineers, January 2022
# Edited April 2022, for Revit 2023
# Edited June 2022, to fix a few bugs and make it run a bit smoother and make it more user-friendly



# Imports the Forms module
Add-Type -assembly System.Windows.Forms

# Declare Variables
$revitVersions = @() # Array that contains the versions of Revit the script will modify
$user = $env:username # Users's logon username
$whichOffice = "SLC"
$whichDepartment = $null
$date = Get-Date -Format "MM-dd-yyyy" # Used in the rename process if a revit ini exists already

# This function gets called later, when the user clicks the "go" button. It is the part that actually moves/replaces files on the disk
function modifyFiles() {
        ForEach ($version in $revitVersions) {
                Start-Sleep -s 1 # pause just so the user can see what's happening
                $statusTextBox.BackColor = "white"
                $statusTextBox.ForeColor = "black"

                # Verifies or creates the Documents\Revit x local folders
                $statusTextBox.Text = "Checking Documents\Revit " + $version + " Local..."
                Start-Sleep -s 1
                if (Test-Path "C:\Users\$user\Documents\Revit $version Local") {
                        $statusTextBox.Text = "Checking Documents\Revit " + $version + " Local... Already Exists"
                }
                else {
                        $statusTextBox.Text = "Checking Documents\Revit " + $version + " Local... Not Found; Creating"

                        # Create the folder
                        mkdir "C:\Users\$user\Documents\Revit $version Local"
                } # end if/else
                
                Start-Sleep -s 2

                # Checks if Revit.INI files exist already, and rename them
                $programDataFolder = "C:\ProgramData\Autodesk\RVT $version\UserDataCache\"
                $appDataFolder = "C:\Users\$user\AppData\Roaming\Autodesk\Revit\Autodesk Revit $version\" 
                $programDataFile = "C:\ProgramData\Autodesk\RVT $version\UserDataCache\Revit.ini"
                $appDataFile = "C:\Users\$user\AppData\Roaming\Autodesk\Revit\Autodesk Revit $version\Revit.ini" 

                # Checks if the folders already exist and creates them if not 
                #Write-Host("The path is... $programDataFolder");
                #Write-Host("The other path is... $appDataFolder");
                if (Test-Path -Path $programDataFolder) {}
                else {
                        $statusTextBox.Text = "Creating ProgramData Folder"
                        New-Item $programDataFolder -ItemType Directory
                }

                # Checks if the folders already exist and creates them if not 
                if (Test-Path -Path  $appDataFolder) {
                }
                else {
                        $statusTextBox.Text = "Creating AppData Folder"
                        New-Item $appDataFolder -ItemType Directory
                }

                # These two if statements remove the file if the code below it was already executed; it saves having to write a more complicated try-catch system and does the same thing
                if (Test-Path "$programDataFolder\Revit $date INI.old") {
                        Remove-Item "$programDataFolder\Revit $date INI.old"
                }
                if (Test-Path "$appDataFolder\Revit $date INI.old") {
                        Remove-Item "$appDataFolder\Revit $date INI.old"
                }

                # Renames the Revit INI file in ProgramData and in Appdata\Roaming if it exists (as a default Revit.ini file)
                if (Test-Path $programDataFile) {
                        Rename-Item -Path $programDataFile -NewName "Revit $date INI.old"
                        $statusTextBox.Text = "Renamed old ProgramData INI File"
                        Start-Sleep -s 1
                } # end if
             
                if (Test-Path $appDataFile) {
                        Rename-Item -Path $appDataFile -NewName "Revit $date INI.old"
                        $statusTextBox.Text = "Renamed old AppData INI File"
                        Start-Sleep -s 1
                }
                
                #Copies the new INI file
                $statusTextBox.Text = "Copying new default INI Files..."
                $currentIniFile = "$PSScriptRoot\ini-files\$version\Revit$version-$whichOffice-$whichDepartment.ini" # The file MUST be in .ps1 root folder\ini-files\<year>!!
                
                try {

                        Copy-Item $currentIniFile -Destination $programDataFile -ErrorAction Stop
                        Copy-Item $currentIniFile -Destination $programDataFolder -ErrorAction Stop
                        Copy-Item $currentIniFile -Destination $appDataFile -ErrorAction Stop
                        Copy-Item $currentIniFile -Destination $appDataFolder -ErrorAction Stop

                }
                catch [System.Management.Automation.ItemNotFoundException] { 
                        $statusTextBox.Text = "No INI file found for " + $version + " " + $whichOffice + " " + $whichDepartment + "."
                        $statusTextBox.BackColor = "darkred"
                        $statusTextBox.ForeColor = "white"
                        return # Breaks out of the foreach loop (like break but break doesn't work here)
                }


                # catch [System.IO.DirectoryNotFoundException] {
                #         $statusTextBox.Text = "File path not found!"
                #         Start-Sleep -s 1
                # }

                #Copy-Item $currentIniFile -Destination $appDataFile
                Start-Sleep -s 1

        } # End foreach
        Start-Sleep -s 1
        $statusTextBox.BackColor = "DarkGreen"
        $statusTextBox.ForeColor = "white"
        $statusTextBox.Text = "Done!"
        $isDone = $true

        $Form.Controls.Remove($goButton)
        $exitButton = New-Object System.Windows.Forms.Button
        $exitButton.Text = "Exit"
        $exitButton.ForeColor = "red"
        $exitButton.Location = '255,295'
        $Form.Controls.Add($exitButton)
        
        $exitButton.Add_Click({ $Form.Close() })

} # end function


# Form Structure
# Initialize the primary Form Object
$Form = New-Object System.Windows.Forms.Form
$Form.width = 360
$Form.height = 400
$Form.Text = "Revit Config Loader"

# Group for the Which Office radio buttons
$OfficeGroup = New-Object System.Windows.Forms.GroupBox
$OfficeGroup.Location = "15,15"
$OfficeGroup.Size = "150,75"
$OfficeGroup.Text = "Office Location"

# Salt Lake Radio button
$radioSLC = New-Object System.Windows.Forms.RadioButton
$radioSLC.Location = "25,20"
$radioSLC.Size = "100, 25"
$radioSLC.Checked = $true
$radioSLC.Text = "SLC"

# Tempe Radio button
$radioTempe = New-Object System.Windows.Forms.RadioButton
$radioTempe.Location = "25,40"
$radioTempe.Size = "100, 25"
$radioTempe.Checked = $false
$radioTempe.Text = "Tempe"

$OfficeGroup.Controls.AddRange(@($radioSLC, $radioTempe))
$Form.Controls.AddRange(@($OfficeGroup))

# Group for the Checkboxes for Revit Versions
$RevitVerGroup = New-Object System.Windows.Forms.GroupBox
$RevitVerGroup.Location = "15,105"
$RevitVerGroup.Size = "150,150"
$RevitVerGroup.Text = "Revit Version(s)"

# Create the version radio buttons
$ver1 = New-Object System.Windows.Forms.CheckBox
$ver1.Location = "25,20"
$ver1.Size = "100, 25"
$ver1.Checked = $false
$ver1.Text = "2018" # <------- Change the value in quotes to represent a different version. Version 1 is the lowest supported version, version 5 is the highest

$ver2 = New-Object System.Windows.Forms.CheckBox
$ver2.Location = "25,40"
$ver2.Size = "100, 25"
$ver2.Checked = $false
$ver2.Text = "2019"

$ver3 = New-Object System.Windows.Forms.CheckBox
$ver3.Location = "25,60"
$ver3.Size = "100, 25"
$ver3.Checked = $false
$ver3.Text = "2020"

$ver4 = New-Object System.Windows.Forms.CheckBox
$ver4.Location = "25,80"
$ver4.Size = "100, 25"
$ver4.Checked = $false
$ver4.Text = "2021"

$ver5 = New-Object System.Windows.Forms.CheckBox
$ver5.Location = "25,100"
$ver5.Size = "100, 25"
$ver5.Checked = $false
$ver5.Text = "2022"

$ver6 = New-Object System.Windows.Forms.CheckBox
$ver6.Location = "25,120"
$ver6.Size = "100, 25"
$ver6.Checked = $false
$ver6.Text = "2023"



$RevitVerGroup.Controls.AddRange(@($ver1, $ver2, $ver3, $ver4, $ver5, $ver6)) # Add another $ver like the above and to here if you want more versions
$Form.Controls.AddRange(@($RevitVerGroup))

#Group for the Department
$DepartmentGroup = New-Object System.Windows.Forms.GroupBox
$DepartmentGroup.Location = "180,15"
$DepartmentGroup.Size = "150,150"
$DepartmentGroup.Text = "Department"

# Electrical
$radioElectrical = New-Object System.Windows.Forms.RadioButton
$radioElectrical.Location = "25,20"
$radioElectrical.Size = "100, 25"
$radioElectrical.Checked = $true
$radioElectrical.Text = "Electrical"

# Mechanical
$radioMechanical = New-Object System.Windows.Forms.RadioButton
$radioMechanical.Location = "25,40"
$radioMechanical.Size = "100, 25"
$radioMechanical.Checked = $false
$radioMechanical.Text = "Mechanical"

# Technology
$radioTechnology = New-Object System.Windows.Forms.RadioButton
$radioTechnology.Location = "25,60"
$radioTechnology.Size = "100, 25"
$radioTechnology.Checked = $false
$radioTechnology.Text = "Technology"

# Architecture
$radioArchitecture = New-Object System.Windows.Forms.RadioButton
$radioArchitecture.Location = "25,80"
$radioArchitecture.Size = "100, 25"
$radioArchitecture.Checked = $false
$radioArchitecture.Text = "Architecture"

# Disables Tech/Arch until needed.
$radioTechnology.Enabled = $false
$radioArchitecture.Enabled = $false

$DepartmentGroup.Controls.AddRange(@($radioElectrical, $radioMechanical, $radioTechnology, $radioArchitecture))
$Form.Controls.AddRange(@($DepartmentGroup))


# Adds a "Go" Button
$goButton = New-Object System.Windows.Forms.Button
$goButton.Text = "Go"
$goButton.Location = '255,295'
$Form.Controls.Add($goButton)

# Adds a "status" label
$labelInfo = New-Object System.Windows.Forms.Label
$labelInfo.Text = "Status:"
$labelInfo.Location = New-Object System.Drawing.Point(15, 305)
$labelInfo.AutoSize = $true
$Form.Controls.Add($labelInfo)


# Adds a text box
$statusTextBox = New-Object System.Windows.Forms.TextBox
$statusTextBox.BackColor = "white"
$statusTextBox.Location = "15,325"
$statusTextBox.Size = "315,25"
$statusTextBox.Text = "Waiting for User Input"
$statusTextBox.ReadOnly = $true # Normally editable, but this prevents user input
$Form.Controls.Add($statusTextBox)

# Form Logic

# Reads the values of the Revit Versions Installed checkboxes and converts them to integers, then puts them in an array.
# This all happens when the "Go" button is clicked and is thus the logic for that button.
$goButton.Add_Click({
        
                $versionButtons = @($ver1, $ver2, $ver3, $ver4, $ver5, $ver6)
                $unchecked=0
                $countOfVersions = $versionButtons.Count # for determining if no versions are actually checked
                $continue = $true

                ForEach ($ver in $versionButtons) {
                        if ($ver.Checked) {
                                $revitVersions = $revitVersions + [int]$ver.Text
                        }
                        else {
                                $unchecked = $unchecked + 1
                                if ($unchecked -eq $countOfVersions) {
                                        $statusTextBox.BackColor = "darkred"
                                        $statusTextBox.ForeColor = "white"
                                        $statusTextBox.Text = "No versions checked! Try again."
                                        $continue = $false
                                }


                        }
                }

                if ($continue) {

                        # Logic for checking which office is selected
                        if ($radioSLC.checked) {
                                $whichOffice = "SLC"
                        }
                        elseif ($radioTempe.checked) {
                                $whichOffice = "Tempe"
                        }
                        else {
                                $whichOffice = "SLC"
                        }

                        # Logic for checking which department
                        $departmentRadios = @($radioElectrical, $radioMechanical, $radioTechnology, $radioArchitecture)
                        ForEach ($dept in $departmentRadios) {
                                if ($dept.Checked) {
                                        $whichDepartment = $dept.Text
                                }
                        }
        
                        # Output to the status box
                        $statusTextBox.BackColor = "white"
                        $statusTextBox.ForeColor = "black"
                        $statusTextBox.Text = "Loading: " + $whichOffice + " / " + $whichDepartment + " / " + $revitVersions
                        Start-Sleep -s 2
                        modifyFiles

                }

        }) # End of Add_Click

# PLACE AT END OF FILE
$Form.ShowDialog() # Makes the form visible
