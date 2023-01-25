$user = $env:username
$StartingDirectory = Get-Location
Write-Host "`n------------------------------------------------------------------------------------"
Write-Host "Bluebeam Cache Drive Mover`n"
Write-Host "NOTE: Please make sure this script is ran as Administrator and that Bluebeam is closed!`n"
$DriveLetter = Read-Host -Prompt 'Enter drive letter for cache drive'
$DriveLetter = $DriveLetter.ToUpper()



# Mounts the applicable drive
if (Test-Path "$DriveLetter`:\BluebeamCache\$user") {
    Write-Host "Folder on '$DriveLetter' Exists Already"
}
else {
    # Set-Location  "$DriveLetter`:"
    mkdir "$DriveLetter`:\BluebeamCache\$user"
    Write-Host "Created Folder"
    
}

# Move the folders to the external drive
Write-Host "Moving Bluebeam Cache files to the $DriveLetter Drive"
Move-Item "C:\Users\$user\AppData\Local\Revu" -Destination "$DriveLetter`:\BluebeamCache\$env:username" # THIS IS WHERE THE STUFF GOES

Write-Host "Creating Symbolic Links"
Set-Location "C:\Users\$user\AppData\Local\Revu"

# Links the PacCache Folder
New-Item -ItemType SymbolicLink -Path "C:\Users\$user\AppData\Local\Revu" -Target "$DriveLetter`:\BluebeamCache\$env:username"


Set-Location $StartingDirectory
