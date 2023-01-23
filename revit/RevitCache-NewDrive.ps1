# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
# Unblock-File *filename*

# Variable Declaration
# Change these when new autodesk versions are released / old ones leave support
$OldestVersion = 2017
$NewestVersion = 2023
$user = $env:username
$StartingDirectory = Get-Location

Write-Host "`n------------------------------------------------------------------------------------"
Write-Host "Autodesk Cache Drive Mover`n"
Write-Host "NOTE: Please make sure this script is ran as Administrator and that Revit is closed!`n"
$DriveLetter = Read-Host -Prompt 'Enter drive letter for cache drive'
$DriveLetter = $DriveLetter.ToUpper()

# Creates a blank array of the versions to modify
$Versions = New-Object System.Collections.ArrayList($null) 

Write-Host "`nWhat versions of Revit are installed? (y/n)"
for ($i = $OldestVersion; $i -le $NewestVersion; $i++) {

    $Installed = Read-Host -Prompt "$i"

    if ($installed -eq "y" -Or $installed -eq "yes" -Or $installed -eq "Y") {
        [void]($Versions.Add($i))
    } # End if

} # End for

# Mounts the applicable drive
if (Test-Path "$DriveLetter`:\RevitCache\$user") {
    Write-Host "Folder on '$DriveLetter' Exists Already"
}
else {
    # Set-Location  "$DriveLetter`:"
    mkdir "$DriveLetter`:\RevitCache\$user"
    Write-Host "Created Folder"
    
}

Write-Host "Closing Revit Accelerator...."
taskkill /IM RevitAccelerator.exe /F

# Move the folders to the external drive
Write-Host "Moving Revit Cache files to the $DriveLetter Drive"
Move-Item "C:\Users\$user\AppData\Local\Autodesk\Revit\PacCache" -Destination "$DriveLetter`:\RevitCache\$env:username"


ForEach ($v in $Versions) {

    Move-Item "C:\Users\$user\AppData\Local\Autodesk\Revit\Autodesk Revit $v" -Destination "$DriveLetter`:\RevitCache\$env:username"

} # end ForEach


# Creates a folder symbolic link for the new folder
Write-Host "Creating Symbolic Links"
Set-Location "C:\Users\$user\AppData\Local\Autodesk\Revit"

# Links the PacCache Folder
New-Item -ItemType SymbolicLink -Path "C:\Users\$user\AppData\Local\Autodesk\Revit\PacCache" -Target "$DriveLetter`:\RevitCache\$env:username\PacCache"

# Links all folders for the specified Revit versions
ForEach ($v in $Versions) {

    New-Item -ItemType SymbolicLink -Path "C:\Users\$user\AppData\Local\Autodesk\Revit\Autodesk Revit $v" -Target "$DriveLetter`:\RevitCache\$env:username\Autodesk Revit $v"
 
} # end ForEach

# Write-Host "Restarting Revit Accelerator...."
# start-process RevitAccelerator # (This might not work)

Set-Location $StartingDirectory
