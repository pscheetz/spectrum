$Users = (Get-ChildItem C:\Users).Name
ForEach($User in $Users) {
    New-Item "C:\users\$User\Documents\Revit 2023 Local" -ItemType Directory -ErrorAction SilentlyContinue
}

Write-Host $Users