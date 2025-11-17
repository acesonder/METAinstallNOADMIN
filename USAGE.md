# Usage Guide

## Windows Desktop Application

### Getting Started

1. **Build and Run:**
   ```bash
   cd WindowsApp
   dotnet run
   ```

2. **Using the Application:**

   **To Install an MSI (No Admin):**
   - Click "Browse..." next to "MSI Installer File"
   - Select your `.msi` file
   - Click "Install MSI (No Admin)"
   - Follow any on-screen prompts from the installer
   - Check the status box for results

   **To Extract MSI Contents:**
   - Click "Browse..." next to "MSI Installer File"
   - Select your `.msi` file
   - Optionally, click "Browse..." next to "Extract to Folder" to choose a custom location
   - Click "Extract MSI Contents"
   - Wait for completion
   - Open the generated `readmeINSTALL.html` file in your browser

### Example Scenarios

**Scenario 1: Installing Software Without Admin Rights**
```
1. Select an MSI file (e.g., MyApp.msi)
2. Click "Install MSI (No Admin)"
3. The app will install to user-accessible locations like:
   %LOCALAPPDATA%\Programs\MyApp\
```

**Scenario 2: Examining an MSI Before Installation**
```
1. Select an MSI file
2. Choose an extraction folder (e.g., C:\Users\YourName\Documents\MyApp_Extract)
3. Click "Extract MSI Contents"
4. Review the readmeINSTALL.html to see all files
5. Manually copy files if needed
```

## Web Application

### Getting Started

1. **Build and Run:**
   ```bash
   cd WebApp
   dotnet run
   ```

2. **Access the Application:**
   - Open your browser to `https://localhost:5001` or `http://localhost:5000`
   - You'll see the MSI Installer web interface

3. **Using the Web Interface:**

   **To Install an MSI:**
   - Click "Choose File" and select your MSI file
   - Click "Install MSI (No Admin)"
   - Wait for the operation to complete
   - Check the status message

   **To Extract MSI Contents:**
   - Click "Choose File" and select your MSI file
   - Optionally specify a custom extraction path
   - Click "Extract MSI Contents"
   - Wait for completion
   - Click "View Installation Guide" to see the generated documentation

### Example Scenarios

**Scenario 1: Remote MSI Management**
```
1. Deploy the web app to a Windows server
2. Access it from any device with a browser
3. Upload MSI files and manage installations remotely
```

**Scenario 2: Batch Documentation**
```
1. Upload multiple MSI files one at a time
2. Extract each to a different folder
3. Generate documentation for all packages
4. Share the readmeINSTALL.html files with your team
```

## Understanding the Generated readmeINSTALL.html

The automatically generated HTML file contains:

### 1. Extraction Metadata
- Date and time of extraction
- Full path where files were extracted

### 2. Complete File Tree
- Hierarchical view of all folders
- List of all files with sizes
- Easy-to-navigate structure

### 3. Installation Guidelines
- Standard installation paths for Windows applications
- User-accessible alternatives for non-admin scenarios
- Best practices for manual installation

### Example Output
```
MSI Installation Guide
======================

Extraction Date: 2025-11-17 17:00:00
Extract Location: C:\Users\John\Documents\MSI_Extract_MyApp

File and Folder Structure
--------------------------
📁 ProgramFilesFolder/
    📁 MyApp/
        📄 MyApp.exe (2.5 MB)
        📄 config.json (1.2 KB)
        📁 Resources/
            📄 logo.png (45 KB)
...
```

## Tips and Best Practices

### For Installing Without Admin:
1. **Choose appropriate MSI files** - Not all MSI packages support per-user installation
2. **Check installation logs** - Use the status box to monitor progress
3. **Manual installation fallback** - If installation fails, try extraction and manual file copying

### For Extracting:
1. **Use meaningful folder names** - Name extraction folders after the application
2. **Keep documentation** - Save the readmeINSTALL.html for future reference
3. **Check file permissions** - Ensure you have write access to the extraction folder

### Troubleshooting

**Problem: Installation fails with "requires administrator"**
- **Solution:** Use the extraction feature instead and manually copy files to user directories

**Problem: Extraction produces empty folder**
- **Solution:** Some MSI files may be encrypted or protected. Try running as administrator (temporarily)

**Problem: readmeINSTALL.html shows limited information**
- **Solution:** The MSI may have nested or compressed content. Check subdirectories manually

**Problem: Web app can't find msiexec**
- **Solution:** Ensure you're running on a Windows system with msiexec.exe available (standard on all Windows versions)

## Advanced Usage

### Custom Installation Paths

To install to a specific location (when supported by the MSI):
1. Extract the MSI first
2. Review the file structure in readmeINSTALL.html
3. Manually copy files to your desired location
4. Create shortcuts as needed

### Scripting

The Windows application can be automated, but for command-line use, consider using `msiexec` directly:

```cmd
REM Install for current user
msiexec /i "app.msi" ALLUSERS=2 MSIINSTALLPERUSER=1 /qb

REM Extract contents
msiexec /a "app.msi" /qn TARGETDIR="C:\Extract"
```

## Security Notes

- Both applications use standard Windows utilities (msiexec.exe)
- No elevated privileges are requested or required
- Files are processed in user-accessible locations only
- Web app cleans up temporary uploaded files automatically
- All operations respect Windows user access controls

## Support and Limitations

### Supported:
✓ Standard MSI installers
✓ Per-user installations
✓ MSI extraction to any writable folder
✓ Automatic documentation generation
✓ Windows 7 and later

### Not Supported:
✗ MSI files requiring mandatory admin privileges
✗ Encrypted or protected MSI packages (limited access)
✗ Linux/Mac MSI handling (Windows-only tool)
✗ MSI creation or editing (only installation/extraction)

## Further Reading

- [Microsoft Docs: msiexec command-line options](https://learn.microsoft.com/windows/win32/msi/command-line-options)
- [Windows Installer (MSI) Technology](https://learn.microsoft.com/windows/win32/msi/windows-installer-portal)
- [Per-User Installation Guidelines](https://learn.microsoft.com/windows/win32/msi/installation-context)
