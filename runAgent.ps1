# Avoid to continue if an error occurred
trap {
    Write-Error $_
    exit 1
}

$configFiles = Get-ChildItem $Env:BUILDAGENT/conf

if($configFiles.Length -lt 1)
{
    Copy-Item $Env:BUILDAGENT/conf.bak/* $Env:BUILDAGENT/conf
}

& "$Env:BUILDAGENT/bin/agent.bat" @("start")

# Wait for the others java processes created by the batch script.
while ($true) {
    Wait-Process -Name "java"   
    Start-Sleep 2
}