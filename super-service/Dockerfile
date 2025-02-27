# 
# This is a multi stage docker build
####
# Stage-1 - To build the app and publish it
####
# official .NET SDK as a build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

# Copy the project files from current dir and restore dependencies
COPY src/. ./
RUN dotnet restore

# publish the application release as output
RUN dotnet publish -c Release -o /app/publish --no-restore

#####
# Stage-2 - Use the build lib from stage-1 and run it as container
######
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS final

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the working directory
WORKDIR /app

# Copy the published application release from the build stage
COPY --from=build /app/publish .

# Set file permissions
RUN chown -R appuser:appgroup /app \
    && chmod -R 755 /app \
    && chmod -R 644 /app/appsettings*.json

# Switch to the non-root user
USER appuser

# Expose only http and https ports
EXPOSE 443 80

# Use read-only file system
VOLUME ["/app"]

# Run the application
ENTRYPOINT ["dotnet", "SuperService.dll"]