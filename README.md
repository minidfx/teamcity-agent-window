# teamcity-agent-window

[![Docker Stars](https://img.shields.io/docker/stars/minidfx/teamcity-agent-window.svg)](https://hub.docker.com/r/minidfx/teamcity-agent-window/) [![Docker Pulls](https://img.shields.io/docker/pulls/minidfx/teamcity-agent-window.svg)](https://hub.docker.com/r/minidfx/teamcity-agent-window/) [![Docker Pulls](https://img.shields.io/docker/automated/minidfx/teamcity-agent-window.svg)](https://hub.docker.com/r/minidfx/teamcity-agent-window/)

The base image for running your teamcity agents on Windows.

For extending this image, just add it as base in your *Dockerfile*

    FROM minidfx/teamcity-agent-window
    
For building the image with your own tag, you have to

* build the **Waiter** application by exectuting the command `dotnet build --configuration Release` in the **Waiter** folder.
* change the environment variable **TEAMCITY_SERVER** with your server url, for instance: `ENV TEAMCITY_SERVER "http://my.teamcity.server.com:8111".
    
This image contains the following dependencies
* Java runtime (for running the agent)
* .NET core (for waiting for any java processes)
* 7-zip (for extracting the JRE \*.tar.gz)
