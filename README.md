# Timestamp Generator
This repository holds application code and deployment files.

### Introduction
Its a .NET Application which generates current date timestamp, and is exposed as a REST API.

### Project Structure

The Model and Controller class are present inside ```/super-service/src/```. The ```Dockerfile``` and ```docker-compose.yaml``` is present inside ```/super-service``` which is used to containerize the application. <br/>

Deploy.ps1 is a wrapper script that will perform the following actions:
1. Run automated unit tests which are present under ```/super-service/tests```
2. Install self signed https certificate, add it to the OS.X keychain or credential manager.
3. Run the docker-compose file to setup network, build docker image and run the built image as a docker container. (This deployment is done locally)

### Getting Started

This application is developed and tested with the following software versions: <br/>

| Software   |      Version   |
|----------|:-------------:|
| MAC OSX |  14.7.3 | $1600 |
| .Net SDK |    9.0.101   |
| Powershell (pwsh) | 7.2.5 |

1. Install .NET SDK

- **Install Homebrew (if not already installed) :** <br/>
```/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"```

- **Tap into the .NET SDK versions :** <br/>
```brew tap isen-ng/dotnet-sdk-versions```

- **Install .NET SDK 9.0.101 :** <br/>
```brew install --cask dotnet-sdk9-0-101```

-  **Verifying the Installation :** <br/>
```dotnet --list-sdks```

2. Install Powershell

- ```brew install --cask powershell@7.2.5```

- ```pwsh --version```

### Installation

Run the ```Deploy.ps1``` script which is present at the root of this project to deploy the application locally 

- ```sudo pwsh Deploy.ps1```

Post deployment you can access the application on browser at - ``` https://localhost/time```

### Improvements

1. Upgraded the .NET sdk version from ```netcoreapp3.1``` to ```net9.0```
2. Added Logs message in controller class after every API call to get the time using ```ILogger``` this is to enable logging post deployment.
3. Updated the ```http and https``` ports from ```5000 & 5001``` to ```80 & 443```

### Deployment Overview

<img width="1463" alt="image" src="https://github.com/user-attachments/assets/fa8ac6e8-4522-43f5-bb2f-b32f432aa9bb" />


