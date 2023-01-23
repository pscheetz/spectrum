$Logfile = "$PSScriptRoot\log.txt"

function WriteLog{

    Param ([string]$LogString)
    $TimeLog = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$TimeLog $LogString"
    Add-Content $LogFile -value $LogMessage
}
WriteLog "`n`n*******Program Start on $env:computername by user $env:username*******"

WriteLog "Testing the log!"
WriteLog "Testing from $env:computername"
WriteLog "Testing from user $env:username"
