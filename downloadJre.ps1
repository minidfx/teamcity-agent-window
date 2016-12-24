param([Parameter(Mandatory=$True, Position=1)] $Uri, [Parameter(Mandatory=$True, Position=2)] $OutFile)

# Avoid to continue if an error occurred
trap {
    Write-Error $_
    exit 1
}

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession   
$cookie = New-Object System.Net.Cookie 

$cookie.Name = "oraclelicense"
$cookie.Value = "accept-securebackup-cookie"
$cookie.Domain = ".oracle.com"

# $session.Cookies.Add($cookie1)
$session.Cookies.Add($cookie)

Invoke-WebRequest -Uri $Uri -WebSession $session -OutFile $OutFile