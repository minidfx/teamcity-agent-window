FROM microsoft/windowsservercore

MAINTAINER Burgy Benjamin <minidfx@gmail.com>

ENV BUILDAGENT "C:/buildAgent"
ENV WAITER "C:/Waiter"
ENV INSTALL "C:/Install"
ENV TEAMCITY_SERVER "<your server url>"

RUN mkdir "%INSTALL%"

# Prepare application for waiting for java processes when the agent is started.
COPY Waiter/src/Wait/bin/Release/netcoreapp1.0 $WAITER
COPY downloadJre.ps1 $INSTALL
COPY runAgent.ps1 $INSTALL

# Move to install directory
WORKDIR $INSTALL

# Downloads dependencies
RUN powershell -NoProfile -Command ./downloadJre.ps1 "http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jre-8u112-windows-x64.tar.gz" -OutFile "jre.tar.gz"; \
                                   Invoke-WebRequest "$Env:TEAMCITY_SERVER/update/buildAgent.zip" -OutFile "buildAgent.zip"; \
                                   Invoke-WebRequest "http://www.7-zip.org/a/7z1604-x64.msi" -OutFile "7z.msi"; \
                                   Invoke-WebRequest "https://download.microsoft.com/download/1/4/1/141760B3-805B-4583-B17C-8C5BC5A876AB/Installers/dotnet-dev-win-x64.1.0.0-preview2-1-003177.exe" -OutFile "dotnetcore.exe"; \
                                   Expand-Archive buildAgent.zip -DestinationPath $Env:BUILDAGENT

# Install 7z for extracting java
RUN msiexec /i 7z.msi /qn /quiet /norestart && \
    "%ProgramFiles%/7-Zip/7z.exe" e jre.tar.gz && \
    "%ProgramFiles%/7-Zip/7z.exe" x jre.tar && \
    dotnetcore.exe /install /quiet /norestart && \
    powershell -NoProfile -Command Move-Item jre1.8.0_112 $Env:BUILDAGENT; \
                                   Rename-Item $Env:BUILDAGENT/jre1.8.0_112 jre


# Post job for preparing the teamcity agent
RUN powershell -NoProfile -Command "New-Item $Env:BUILDAGENT/work -ItemType directory -Force | Out-Null; \
                                    Rename-Item $Env:BUILDAGENT/conf conf.bak; \
                                    New-Item $Env:BUILDAGENT/conf -ItemType directory -Force | Out-Null;"

VOLUME $BUILDAGENT/conf
VOLUME $BUILDAGENT/logs

EXPOSE 9090

# Run the small application for waiting for any java processes.
CMD powershell -File "%INSTALL%/runAgent.ps1"