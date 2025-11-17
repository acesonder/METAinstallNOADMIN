# Build Instructions

## Prerequisites

- .NET 10.0 SDK or later
- Windows OS (for running the applications)
- Git (for cloning the repository)

## Quick Start

### Clone the Repository
```bash
git clone https://github.com/acesonder/METAinstallNOADMIN.git
cd METAinstallNOADMIN
```

### Build All Projects
```bash
# Build the entire solution
dotnet build METAinstallNOADMIN.sln

# Or build individual projects
cd WindowsApp
dotnet build

cd ../WebApp
dotnet build
```

## Running the Applications

### Windows Desktop Application

```bash
cd WindowsApp
dotnet run
```

This will launch the Windows Forms GUI application.

**Alternative - Publish for Windows:**
```bash
cd WindowsApp
dotnet publish -c Release -r win-x64 --self-contained true
```

The executable will be in `WindowsApp/bin/Release/net10.0-windows/win-x64/publish/MSIInstaller.exe`

### Web Application

```bash
cd WebApp
dotnet run
```

Then open your browser to:
- HTTPS: `https://localhost:5001`
- HTTP: `http://localhost:5000`

**For production deployment:**
```bash
cd WebApp
dotnet publish -c Release -o ./publish
```

The published files will be in `WebApp/publish/`

## Build Configuration

### Debug Build (Default)
```bash
dotnet build -c Debug
```

### Release Build (Optimized)
```bash
dotnet build -c Release
```

## Cleaning Build Artifacts

```bash
# Clean all build artifacts
dotnet clean

# Clean and rebuild
dotnet clean && dotnet build
```

## Platform-Specific Builds

The Windows application targets Windows specifically due to Windows Forms dependency:

```xml
<TargetFramework>net10.0-windows</TargetFramework>
<UseWindowsForms>true</UseWindowsForms>
```

The Web application can be built on any platform but must be run on Windows to execute MSI operations:

```xml
<TargetFramework>net10.0</TargetFramework>
```

## Publishing for Distribution

### Windows Desktop App - Self-Contained Executable

```bash
cd WindowsApp
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true
```

This creates a single executable that includes the .NET runtime.

### Windows Desktop App - Framework-Dependent

```bash
cd WindowsApp
dotnet publish -c Release -r win-x64 --self-contained false
```

Smaller file size but requires .NET to be installed on the target machine.

### Web App - IIS Deployment

```bash
cd WebApp
dotnet publish -c Release -o ./publish
```

Copy the `publish` folder to your IIS web server and configure the application pool.

### Web App - Docker (Windows Container)

Create a `Dockerfile` in the WebApp directory:
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:10.0-nanoserver-ltsc2022
WORKDIR /app
COPY publish/ .
ENTRYPOINT ["dotnet", "MSIInstallerWeb.dll"]
```

Build and run:
```bash
dotnet publish -c Release -o ./publish
docker build -t msi-installer-web .
docker run -p 8080:8080 msi-installer-web
```

## Troubleshooting

### Error: "NETSDK1100: To build a project targeting Windows"

This is expected when building on non-Windows platforms. The Windows Forms app requires Windows. The project is configured with:
```xml
<EnableWindowsTargeting>true</EnableWindowsTargeting>
```

### Error: "msiexec is not recognized"

MSI operations require Windows. Ensure you're running on a Windows system.

### Web App Cannot Start

Check if ports 5000/5001 are available:
```bash
# Change the port in WebApp/Properties/launchSettings.json
{
  "profiles": {
    "http": {
      "applicationUrl": "http://localhost:5000"
    },
    "https": {
      "applicationUrl": "https://localhost:5001"
    }
  }
}
```

## Build Output

After a successful build, you'll find:
- **WindowsApp**: `WindowsApp/bin/Debug/net10.0-windows/MSIInstaller.dll`
- **WebApp**: `WebApp/bin/Debug/net10.0/MSIInstallerWeb.dll`

## IDE Support

### Visual Studio 2022 or later
1. Open `METAinstallNOADMIN.sln`
2. Press F5 to build and run
3. Right-click on project → Publish for deployment

### Visual Studio Code
1. Install C# Dev Kit extension
2. Open the folder in VS Code
3. Use integrated terminal for `dotnet` commands
4. Use F5 for debugging

### JetBrains Rider
1. Open `METAinstallNOADMIN.sln`
2. Use built-in run configurations
3. Access publish options from Build menu

## Continuous Integration

Example GitHub Actions workflow:

```yaml
name: Build

on: [push, pull_request]

jobs:
  build:
    runs-on: windows-latest
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-dotnet@v3
      with:
        dotnet-version: '10.0.x'
    - run: dotnet build METAinstallNOADMIN.sln
    - run: dotnet publish WindowsApp/MSIInstaller.csproj -c Release
    - run: dotnet publish WebApp/MSIInstallerWeb.csproj -c Release
```

## Additional Resources

- [.NET SDK Documentation](https://learn.microsoft.com/dotnet/core/sdk)
- [Windows Forms in .NET](https://learn.microsoft.com/dotnet/desktop/winforms/)
- [ASP.NET Core Documentation](https://learn.microsoft.com/aspnet/core/)
- [Publishing .NET Applications](https://learn.microsoft.com/dotnet/core/deploying/)
