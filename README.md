# METAinstallNOADMIN

MSI Installer applications that allow you to install or extract MSI files without requiring elevated administrator privileges.

## 🎯 Features

- **Install MSI files without admin rights** - Uses per-user installation flags to install MSI packages for the current user only
- **Extract MSI contents** - Extract all files from an MSI package to a folder of your choice
- **Automatic documentation generation** - Generates a detailed `readmeINSTALL.html` file showing:
  - Complete file and folder structure
  - File sizes and locations
  - Installation instructions for manual deployment
  - Recommended installation paths for non-admin scenarios
- **Comprehensive testing tools** - Included scripts to verify functionality with any MSI file
  - Automated verification script
  - Specific application testing
  - Detailed reporting and analysis

## 📦 Applications

This repository contains two implementations:

### 1. Windows Desktop Application (`WindowsApp/`)

A Windows Forms desktop application with a user-friendly GUI.

**Requirements:**
- Windows OS
- .NET 10.0 or later

**Build:**
```bash
cd WindowsApp
dotnet build
```

**Run:**
```bash
dotnet run
```

**Features:**
- File browser for easy MSI selection
- Folder browser for extraction path selection
- Real-time status updates
- Default extraction path suggestion
- Clean, intuitive interface

### 2. Web Application (`WebApp/`)

An ASP.NET Core web application that provides the same functionality through a browser interface.

**Requirements:**
- Windows OS (for MSI operations)
- .NET 10.0 or later
- Web browser

**Build:**
```bash
cd WebApp
dotnet build
```

**Run:**
```bash
dotnet run
```

Then open your browser to `https://localhost:5001` or `http://localhost:5000`

**Features:**
- Upload MSI files through web interface
- Specify custom extraction paths
- View generated installation guide in browser
- Works remotely if hosted on a Windows server
- Responsive design for mobile/desktop

## 🚀 How It Works

### Installing MSI Files (No Admin)

Both applications use `msiexec.exe` with special flags to perform per-user installation:

```
msiexec.exe /i "path\to\file.msi" ALLUSERS=2 MSIINSTALLPERUSER=1 /qb
```

- `ALLUSERS=2` - Enables per-user installation
- `MSIINSTALLPERUSER=1` - Forces per-user context
- `/qb` - Shows a basic UI during installation

**Note:** Some MSI packages may have hardcoded requirements for administrator privileges. In such cases, the installation may fail, but the extraction feature will still work.

### Extracting MSI Contents

Uses administrative installation mode of msiexec:

```
msiexec.exe /a "path\to\file.msi" /qn TARGETDIR="extraction\path"
```

This extracts all files from the MSI package without installing them, allowing you to:
- See exactly what files would be installed
- Manually copy files to appropriate locations
- Understand the application's structure
- Create custom installation scripts

### Generated Documentation

After extraction, a `readmeINSTALL.html` file is automatically created with:

- **Extraction metadata** - Date, time, and location
- **Complete file tree** - All folders and files with sizes
- **Installation guidelines** - Where files should typically be placed
- **Non-admin alternatives** - User-accessible installation paths

## 📋 Use Cases

1. **Installing software without admin rights** - Perfect for locked-down corporate environments or shared computers
2. **Understanding MSI packages** - See what files and folders an MSI contains before installation
3. **Creating portable applications** - Extract and manually place files in user directories
4. **Software deployment** - Generate documentation for IT teams
5. **Troubleshooting installations** - Examine MSI contents to understand installation failures

## 🔒 Security Considerations

- The applications use standard Windows MSI utilities (`msiexec.exe`)
- No elevated privileges are required for per-user installations
- Extraction is performed in user-accessible directories
- Web application saves uploaded files temporarily and cleans them up after processing
- All file operations respect Windows user permissions

## 💡 Tips for Non-Admin Installation

When installing without admin rights, applications typically install to:
- `%LOCALAPPDATA%\Programs\` - Recommended for program files
- `%APPDATA%\` - For application data
- `%USERPROFILE%\` - For user-specific installations

If an MSI fails to install without admin rights, try:
1. Extracting the contents first
2. Manually copying files to `%LOCALAPPDATA%\Programs\[AppName]\`
3. Creating shortcuts manually if needed
4. Checking the generated `readmeINSTALL.html` for guidance

## 🛠️ Development

**Project Structure:**
```
METAinstallNOADMIN/
├── WindowsApp/          # Windows Forms desktop application
│   ├── Form1.cs         # Main form logic
│   ├── Form1.Designer.cs # UI design
│   └── MSIInstaller.csproj
├── WebApp/              # ASP.NET Core web application
│   ├── Pages/
│   │   ├── Index.cshtml      # Main page UI
│   │   └── Index.cshtml.cs   # Page logic
│   └── MSIInstallerWeb.csproj
└── README.md
```

**Building both applications:**
```bash
# Build Windows app
cd WindowsApp
dotnet build

# Build Web app
cd ../WebApp
dotnet build
```

## 🧪 Testing and Verification

To verify that the MSI extraction and installation functionality works correctly, use the included testing tools:

### Quick Test with Any MSI File
```cmd
Test-MSI.bat "C:\path\to\your.msi"
```

### Comprehensive Verification
```powershell
# Basic verification (no MSI required)
.\Verify-MSIExtraction.ps1

# Full verification with test MSI
.\Verify-MSIExtraction.ps1 -TestMsiPath "C:\path\to\test.msi"
```

### Detailed Testing of Specific Applications
```powershell
# Test World Creator or any specific app
.\Test-SpecificMSI.ps1 -MsiPath "C:\path\to\app.msi" -AppName "MyApp"

# Extract only (skip installation)
.\Test-SpecificMSI.ps1 -MsiPath "C:\path\to\app.msi" -ExtractOnly
```

For complete testing instructions, see [TESTING.md](TESTING.md).

## 📄 License

This project is provided as-is for educational and practical use. Feel free to modify and distribute as needed.

## ⚠️ Disclaimer

- This tool works with standard MSI packages on Windows
- Some MSI files may have specific requirements that prevent non-admin installation
- Always verify extracted contents before manual installation
- Use at your own risk; the authors are not responsible for any issues arising from use of this software