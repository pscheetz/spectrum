# This script is intented to remove duplicate files. like when Bluebeam signature stamps re-create themselves every time they are used.
# It gets rid of files like this: file(1).example, file(999).example, but not file.example

# Intended to be used for S:\01Spectrum\Office\PDF Stamps

# USE WITH CAUTION as it is recursive and can destroy things if you are not careful
# (Remove the -recurse after Get-ChildItem to not do it recursively)

$Files = Get-ChildItem -recurse | Where-Object Name -Like "*(*)*"
Write-Host "There are " $Files.Count " Duplicate Files"

foreach ($File in $Files) {
    Remove-Item $File
}
Write-Host "Done removing duplicates"