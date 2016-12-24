FROM microsoft/dotnet-framework:4.6.2

MAINTAINER Burgy Benjamin <benjamin@setza.com>

ENV INSTALL_FOLDER "C:/Install"
ENV DOTNETCORE "C:/Program Files/dotnet"
ENV NODEJS "C:/Program Files/nodejs"
ENV BUILDAGENT "C:/buildAgent"
ENV WAITER "C:/Waiter"

# Create and move into the folder which will contains dependencies.
RUN powershell -NoProfile -Command "New-Item $Env:INSTALL_FOLDER -ItemType directory | Out-Null"
WORKDIR $INSTALL_FOLDER

COPY Waiter/src/Wait/bin/Release/netcoreapp1.0 $WAITER
COPY downloadJre.ps1 $WAITER
COPY runAgent.ps1 $WAITER

# Downloads dependencies
RUN powershell -NoProfile -Command Invoke-WebRequest "http://roomzoverdocker.cloudapp.net:8111/update/buildAgent.zip" -OutFile "buildAgent.zip"; \
                                   Invoke-WebRequest "https://nodejs.org/dist/v6.9.2/node-v6.9.2-x64.msi" -OutFile "node.msi"; \
                                   Invoke-WebRequest "https://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_amd64_en-US.msi" -OutFile "webdeploy.msi"; \
                                   Invoke-WebRequest "https://download.microsoft.com/download/F/1/D/F1DEB8DB-D277-4EF9-9F48-3A65D4D8F965/NDP461-DevPack-KB3105179-ENU.exe" -OutFile "dotnet461-dev-pack.exe"; \
                                   Invoke-WebRequest "https://download.microsoft.com/download/1/4/1/141760B3-805B-4583-B17C-8C5BC5A876AB/Installers/dotnet-dev-win-x64.1.0.0-preview2-1-003177.exe" -OutFile "dotnetcore.exe"

# Install dependencies & update the PATH system environment variable
RUN dotnet461-dev-pack.exe /q /norestart && \
    msiexec /i node.msi /qn /quiet /norestart && \
    msiexec /i webdeploy.msi /qn /quiet /norestart && \
    dotnetcore.exe /install /quiet /norestart && \
    powershell -NoProfile -Command Expand-Archive buildAgent.zip -DestinationPath $Env:BUILDAGENT

COPY jre $BUILDAGENT/jre

# Install additional dependencies
RUN npm install -g bower > nul && \
    npm install -g gulp > nul

# Post job for preparing the teamcity agent
RUN powershell -NoProfile -Command "New-Item $Env:BUILDAGENT/work -ItemType directory -Force | Out-Null; \
                                    Rename-Item $Env:BUILDAGENT/conf conf.bak; \
                                    New-Item $Env:BUILDAGENT/conf -ItemType directory -Force | Out-Null;"

VOLUME $BUILDAGENT/conf
VOLUME $BUILDAGENT/logs

WORKDIR C:/

# Cleanup
RUN powershell -NoProfile -Command Remove-Item $Env:INSTALL_FOLDER -Recurse -Force

EXPOSE 9090

CMD powershell -File "%WAITER%/runAgent.ps1"