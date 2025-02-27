# Enable strict mode for error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Default Project directory
$ProjectDir = "$PSScriptRoot/super-service"

# Default Cert path 
$CertPath = "./https/aspnetapp.pfx"

# Check if the Project Dir exists to continue..
if (-Not (Test-Path $ProjectDir)) {
    Write-Host "Error: Directory '$ProjectDir' does not exist." -ForegroundColor Red
    exit 1
}

# Set the directory.
Set-Location -Path $ProjectDir

# Unit test execution
Write-Host "Running unit tests..."
Push-Location -Path "$ProjectDir\test"
dotnet test
Pop-Location # setting it back to $ProjectDir

if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests Failed.." -ForegroundColor Red
    exit 1
}
Write-Host "Tests passed successfully" -ForegroundColor Green

# Creating a self signed certificate - Note: Do not use this in production env.
Write-Host "Setting up self signed HTTPS certificates.."
Write-Host "Important..!! Do not use self signed certs in production, hope you know what you are doing :)" -ForegroundColor Red

# Check if the certificate already exists
if (Test-Path $CertPath) {
    $confirmDelete = Read-Host "⚠️ Certificate already exists at '$CertPath'. Do you want to delete and regenerate it with new password ? (yes/no)"
    if ($confirmDelete -eq "yes") {
            Write-Host "Deleting existing certificate..."
            Remove-Item -Path $CertPath -Force
            Write-Host "⚠️ Warning..!! Cleaning old HTTPS certificates.."
            
            dotnet dev-certs https --clean
            if($LASTEXITCODE -ne 0) {
                Write-Host "ERROR: Failed to cleaning up of certificates.." -ForegroundColor Red
                exit 1
            }

            # Certificate password
            $CertPassword = Read-Host "Enter a new password for the self signed HTTPS certificate" -AsSecureString
            # To get password as plaintext to export cert
            $CertPasswordPlain = (New-Object PSCredential "user", $CertPassword).GetNetworkCredential().Password
            
            Write-Host "Generating new self signed HTTPS certificates.."
            
            dotnet dev-certs https --trust
            if($LASTEXITCODE -ne 0){
                Write-Host "ERROR: Failed to certificate trust.." -ForegroundColor Red
                exit 1
            }

            Write-Host "Exporting certificate to $CertPath with the given password.."
            
            dotnet dev-certs https -v -ep $CertPath -p sslcert
            if($LASTEXITCODE -ne 0){
                Write-Host "ERROR: Failed to certificate export.." -ForegroundColor Red
                exit 1
            }
            
            # To make pfx file available inside container
            chmod -R 744 "./https"
        
    } else {
        Write-Host "Keeping existing certificate, skipping certification generation step.."
        # Certificate password
        $CertPassword = Read-Host "Enter the existing password for the certificate $CertPath" -AsSecureString
        # To get password as plaintext to export cert
        $CertPasswordPlain = (New-Object PSCredential "user", $CertPassword).GetNetworkCredential().Password
    }
} else {
    # Certificate password
    $CertPassword = Read-Host "Enter a new password for the self signed HTTPS certificate" -AsSecureString
    # To get password as plaintext to export cert
    $CertPasswordPlain = (New-Object PSCredential "user", $CertPassword).GetNetworkCredential().Password

    Write-Host "Generating new self signed  HTTPS certificates.."
        
    dotnet dev-certs https --trust
    if($LASTEXITCODE -ne 0){
        Write-Host "ERROR: Failed to certificate trust.." -ForegroundColor Red
        exit 1
    }

    Write-Host "Exporting certificate to $CertPath with the given password.."
        
    dotnet dev-certs https -v -ep $CertPath -p sslcert
    if($LASTEXITCODE -ne 0){
        Write-Host "ERROR: Failed to certificate export.." -ForegroundColor Red
        exit 1
    }

    # To make pfx file available inside container
    chmod -R 744 "./https"
}

# Updating docker compose with latest password
Write-Host "Updating Docker Compose environment variables..."
$dockerComposeFile = "docker-compose.override.yml"

# overriding the base dockercompose file
$dockerComposeContent = @"
services:
  superservice:
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_Kestrel__Certificates__Default__Password=$CertPasswordPlain
"@

$dockerComposeContent | Set-Content -Path $dockerComposeFile -Encoding utf8

# Starting docker container
Write-Host "Starting Docker Compose..."
docker-compose up --build -d

# Removing the override file created with values
Remove-Item -Path ./docker-compose.override.yml -Verbose

# Wait for containers to start and check status
Start-Sleep -Seconds 5  # wait for 5sec

# Get the status of the container
$containerStatus = docker ps --filter "name=superservice" --format "{{.Status}}"

if (-not $containerStatus -or $containerStatus -match "Exited" -or $containerStatus -match "Restarting") {
    Write-Host "ERROR: Docker container 'superservice' failed to start." -ForegroundColor Red
    docker rm -f "superservice" # forcefully kill and cleanup the container
    exit 1
}

Write-Host "Docker container is running successfully." -ForegroundColor Green
Write-Host "Setup complete! Application is running on:"
Write-Host "   - https://localhost/time"

