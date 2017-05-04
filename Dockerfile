FROM microsoft/windowsservercore

MAINTAINER Burgy Benjamin <minidfx@gmail.com> & Romero Daniel <daniel.romero@baseclass.ch>

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV BUILDAGENT "C:/buildAgent"
ENV INSTALL "C:/Install"
ENV SCRIPTS "C:/Scripts"
ENV TEAMCITY_SERVER "<your server url>"

RUN New-Item -Path $Env:INSTALL -Type directory 
RUN New-Item -Path $Env:SCRIPTS -Type directory 

# Prepare application for waiting for java processes when the agent is started.
COPY downloadJre.ps1 $INSTALL
COPY runAgent.ps1 $SCRIPTS

# Move to install directory
WORKDIR $INSTALL

# Downloads dependencies
RUN ./downloadJre.ps1 -Uri "http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jre-8u112-windows-x64.tar.gz" -OutDest "$Env:BUILDAGENT/jre"; \
    Invoke-WebRequest "$Env:TEAMCITY_SERVER/update/buildAgent.zip" -OutFile "buildAgent.zip"; \
    Expand-Archive buildAgent.zip -DestinationPath $Env:BUILDAGENT

# Post job for preparing the teamcity agent
RUN New-Item $Env:BUILDAGENT/work -ItemType directory -Force | Out-Null; \
    Rename-Item $Env:BUILDAGENT/conf conf.bak; \
    New-Item $Env:BUILDAGENT/conf -ItemType directory -Force | Out-Null;

VOLUME $BUILDAGENT/conf
VOLUME $BUILDAGENT/logs

WORKDIR $BUILDAGENT

# Clean up
RUN Remove-Item $Env:INSTALL -Recurse -Force

EXPOSE 9090

# Run the agent
CMD & "$Env:SCRIPTS/runAgent.ps1"