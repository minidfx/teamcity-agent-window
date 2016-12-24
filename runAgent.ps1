param()

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

& "$Env:BUILDAGENT/bin/agent.bat" start

& dotnet exec "$Env:WAITER/Wait.dll" "$Env:BUILDAGENT/bin/agent.bat" stop