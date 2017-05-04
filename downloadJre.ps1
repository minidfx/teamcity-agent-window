param([Parameter(Mandatory=$True, Position=0)] $Uri, [Parameter(Mandatory=$True, Position=1)] $OutDest)

# Avoid to continue if an error occurred
trap {
    Write-Error $_
    exit 1
}

# Download the SharpZipLib nuget package
[Reflection.Assembly]::LoadWithPartialName("System.IO.Compression") | Out-Null
$httpWebRequest = [System.Net.HttpWebRequest]::CreateHttp("https://www.nuget.org/api/v2/package/SharpZipLib/0.86.0")
$response = $httpWebRequest.GetResponse()
$stream = $response.GetResponseStream()

# Extract the DLL from the nuget package
$zipArchive = New-Object System.IO.Compression.ZipArchive($stream)
$entry = $zipArchive.GetEntry("lib/20/ICSharpCode.SharpZipLib.dll")
$sharpZipStream = $entry.Open()
$memoryStream = New-Object System.IO.MemoryStream
$sharpZipStream.CopyTo($memoryStream)

# Release resources allocated to extract the lib
$zipArchive.Dispose()
$response.Dispose()
$stream.Dispose()
$sharpZipStream.Dispose()

# Load the assembly in memory
[System.Reflection.Assembly]::Load($memoryStream.ToArray())

# Release the stream containing the lib
$memoryStream.Dispose()

# Download Java
$httpWebRequest = [System.Net.HttpWebRequest]::CreateHttp($Uri)
$httpWebRequest.CookieContainer = New-Object System.Net.CookieContainer
$httpWebRequest.CookieContainer.Add($(New-Object System.Net.Cookie("oraclelicense", "accept-secure-backup-cookie", "", ".oracle.com")))
$response = $httpWebRequest.GetResponse()
$stream = $response.GetResponseStream()

# Unzip the tar archive into the given destination
$gzipStream = New-Object ICSharpCode.SharpZipLib.GZip.GZipInputStream($stream)
$tarArchive = [ICSharpCode.SharpZipLib.Tar.TarArchive]::CreateInputTarArchive($gzipStream)
$tarArchive.ExtractContents($OutDest)

# Release resources
$tarArchive.Close()
$tarArchive.Dispose()
$gzipStream.Dispose()
$stream.Dispose()
$response.Dispose()