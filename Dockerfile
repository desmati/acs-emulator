# Stage 1: Build UI
FROM node:18-alpine AS ui-build
WORKDIR /app/ui

# Copy UI package files
COPY AcsEmulator/acs-emulator-ui/package*.json ./
RUN npm ci

# Copy UI source and build
COPY AcsEmulator/acs-emulator-ui/ ./
RUN npm run build

# Stage 2: Build .NET API
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS api-build
WORKDIR /app

# Copy solution and project files
COPY AcsEmulator/AcsEmulator.sln ./
COPY AcsEmulator/AcsEmulatorAPI/AcsEmulatorAPI.csproj ./AcsEmulatorAPI/
COPY AcsEmulator/AcsEmulatorAPI.Tests/AcsEmulatorAPI.Tests.csproj ./AcsEmulatorAPI.Tests/
COPY AcsEmulator/AcsEmulatorCLI/AcsEmulatorCLI.csproj ./AcsEmulatorCLI/

# Restore dependencies
RUN dotnet restore

# Copy the rest of the source code
COPY AcsEmulator/ ./

# Build the API project
RUN dotnet build AcsEmulatorAPI/AcsEmulatorAPI.csproj -c Release -o /app/build

# Publish the API
RUN dotnet publish AcsEmulatorAPI/AcsEmulatorAPI.csproj -c Release -o /app/publish

# Stage 3: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Install SQLite (needed for the database)
RUN apt-get update && apt-get install -y sqlite3 && rm -rf /var/lib/apt/lists/*

# Copy published API
COPY --from=api-build /app/publish .

# Copy built UI files
COPY --from=ui-build /app/ui/build ./wwwroot

# Expose ports
# Port 80/443 for API and Swagger
EXPOSE 80
EXPOSE 443

# Set environment variables
ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Development

# Create directory for database
RUN mkdir -p /app/data

# Run database migrations and start the application
ENTRYPOINT ["dotnet", "AcsEmulatorAPI.dll"]
