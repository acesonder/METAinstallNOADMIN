# Testing Guide for METAinstallNOADMIN

This guide provides comprehensive instructions for testing and verifying the MSI extraction and installation functionality of the METAinstallNOADMIN applications.

## 🎯 Testing Objectives

The testing process verifies that:

1. ✅ MSI packages can be extracted without administrator privileges
2. ✅ MSI packages can be installed for the current user without admin rights (when supported)
3. ✅ The `readmeINSTALL.html` file is generated correctly with complete information
4. ✅ Extracted files maintain proper structure and integrity
5. ✅ Both Windows Desktop and Web applications function correctly
6. ✅ Error handling works properly for various edge cases

## 📋 Prerequisites

### Required Software
- Windows 7 or later (64-bit recommended)
- .NET 10.0 SDK or later ([Download here](https://dotnet.microsoft.com/download))
- PowerShell 5.1 or later (included in Windows 10/11)
- Web browser (for viewing readmeINSTALL.html and testing WebApp)

### Test MSI Files
You'll need at least one MSI file for testing. Recommended sources:

1. **World Creator** - If testing the specific app mentioned in the issue
2. **Sample MSI files** - Any legitimate MSI installer you have access to
3. **Create a test MSI** - Use tools like WiX Toolset to create a simple test MSI

**Note:** Do not use MSI files from untrusted sources.

## 🧪 Automated Verification Script

### Quick Verification (No MSI File)

This runs basic project structure verification without requiring a test MSI:

```powershell
cd path\to\METAinstallNOADMIN
.\Verify-MSIExtraction.ps1
```

This will check:
- ✓ msiexec.exe availability
- ✓ .NET SDK installation
- ✓ Solution builds successfully
- ✓ Project structure is correct
- ✓ Source code contains proper flags and methods

### Full Verification (With Test MSI)

For complete testing with an actual MSI file:

```powershell
cd path\to\METAinstallNOADMIN
.\Verify-MSIExtraction.ps1 -TestMsiPath "C:\path\to\test.msi"
```

This performs all basic checks plus:
- ✓ MSI extraction functionality
- ✓ File extraction verification
- ✓ readmeINSTALL.html generation
- ✓ HTML content validation
- ✓ Installation command structure verification

### Verbose Output

For detailed diagnostic information:

```powershell
.\Verify-MSIExtraction.ps1 -TestMsiPath "C:\path\to\test.msi" -Verbose
```

## 🔍 Testing Specific MSI Applications

Use the `Test-SpecificMSI.ps1` script for detailed testing of individual applications:

### Basic Test (Extract Only)

```powershell
.\Test-SpecificMSI.ps1 -MsiPath "C:\path\to\app.msi" -ExtractOnly
```

This will:
1. Extract the MSI contents
2. Analyze the extracted files
3. Generate a detailed readmeINSTALL.html
4. Open the report in your browser
5. Skip the installation test

### Full Test (Extract + Install)

```powershell
.\Test-SpecificMSI.ps1 -MsiPath "C:\path\to\app.msi"
```

This performs extraction and then prompts you to optionally test installation.

### Testing World Creator

If you have World Creator MSI file:

```powershell
.\Test-SpecificMSI.ps1 -MsiPath "C:\path\to\WorldCreator.msi" -AppName "WorldCreator"
```

### Skip Installation Automatically

```powershell
.\Test-SpecificMSI.ps1 -MsiPath "C:\path\to\app.msi" -SkipInstall
```

## 🖥️ Testing the Windows Desktop Application

### Build and Run

1. **Build the application:**
   ```powershell
   cd WindowsApp
   dotnet build
   ```

2. **Run the application:**
   ```powershell
   dotnet run
   ```

3. **The application window will appear.**

### Manual Testing Steps

#### Test 1: MSI File Selection
1. Click **"Browse..."** next to "MSI Installer File"
2. Select a test MSI file
3. ✅ Verify the path appears in the text box
4. ✅ Verify the default extraction path is auto-populated

#### Test 2: Custom Extraction Path
1. Click **"Browse..."** next to "Extract to Folder"
2. Select a custom folder
3. ✅ Verify the path updates correctly

#### Test 3: MSI Extraction
1. With an MSI file selected, click **"Extract MSI Contents"**
2. Wait for the process to complete
3. ✅ Verify "Extraction completed successfully!" message appears
4. ✅ Verify status box shows extraction progress
5. ✅ Open the extraction folder and verify files are present
6. ✅ Open `readmeINSTALL.html` and verify it contains:
   - Extraction date and time
   - Extract location
   - Complete file tree with file sizes
   - Installation instructions
   - Non-admin installation alternatives

#### Test 4: Per-User Installation
1. Select an MSI file
2. Click **"Install MSI (No Admin)"**
3. A Windows Installer dialog may appear
4. ✅ Verify installation completes (check exit code in status)
5. ✅ Verify application is installed in user directories
6. ✅ Check Start Menu for the application
7. ✅ Verify no UAC prompt appeared (non-admin install)

#### Test 5: Error Handling
1. Try to extract without selecting an MSI file
   - ✅ Verify appropriate error message
2. Try to extract with an invalid file path
   - ✅ Verify appropriate error message
3. Try to install an MSI that requires admin
   - ✅ Verify graceful failure with informative message

## 🌐 Testing the Web Application

### Build and Run

1. **Build the application:**
   ```powershell
   cd WebApp
   dotnet build
   ```

2. **Run the application:**
   ```powershell
   dotnet run
   ```

3. **Open browser to:**
   - HTTPS: `https://localhost:5001`
   - HTTP: `http://localhost:5000`

### Manual Testing Steps

#### Test 1: MSI File Upload
1. Click **"Choose File"** button
2. Select a test MSI file
3. ✅ Verify file name appears next to button

#### Test 2: MSI Extraction via Web
1. Upload an MSI file
2. Optionally specify a custom extraction path
3. Click **"Extract MSI Contents"**
4. Wait for processing
5. ✅ Verify success message with extraction path
6. ✅ Click **"View Installation Guide"** link
7. ✅ Verify readmeINSTALL.html displays correctly in browser
8. ✅ Navigate to extraction folder and verify files

#### Test 3: Per-User Installation via Web
1. Upload an MSI file
2. Click **"Install MSI (No Admin)"**
3. Wait for installation
4. ✅ Verify success or failure message
5. ✅ Check that application is installed for current user

#### Test 4: Multiple Extractions
1. Upload and extract multiple different MSI files
2. ✅ Verify each creates its own folder
3. ✅ Verify each generates its own readmeINSTALL.html
4. ✅ Verify no conflicts between extractions

#### Test 5: Error Handling
1. Try to submit without selecting a file
   - ✅ Verify error message
2. Try to upload a non-MSI file
   - ✅ Verify validation error
3. Upload a very large MSI file
   - ✅ Verify proper handling or timeout

#### Test 6: Temp File Cleanup
1. Upload and process an MSI file
2. Check `%TEMP%` folder for temporary MSI files
3. ✅ Verify temp files are cleaned up after processing

## 📊 Test Results Documentation

### Recording Test Results

Create a test results document with the following template:

```markdown
# Test Results - [Date]

## Environment
- OS: Windows [version]
- .NET Version: [version]
- User Privilege: [Admin/Non-Admin]
- Test MSI: [application name]

## Automated Tests
- Verify-MSIExtraction.ps1: [Pass/Fail]
- Tests Passed: [X/Y]
- Success Rate: [percentage]

## Windows Desktop App Tests
- [ ] MSI Selection: [Pass/Fail]
- [ ] Extraction: [Pass/Fail]
- [ ] README Generation: [Pass/Fail]
- [ ] Installation (No Admin): [Pass/Fail]
- [ ] Error Handling: [Pass/Fail]

## Web Application Tests
- [ ] File Upload: [Pass/Fail]
- [ ] Extraction: [Pass/Fail]
- [ ] README View: [Pass/Fail]
- [ ] Installation (No Admin): [Pass/Fail]
- [ ] Error Handling: [Pass/Fail]

## Notes
[Any observations, issues, or recommendations]
```

## 🐛 Known Issues and Limitations

### MSI Files That May Require Admin
Some MSI packages have hardcoded requirements for administrator privileges:
- System drivers
- Windows services
- Files that must be placed in `C:\Windows\System32\`
- Registry modifications to `HKEY_LOCAL_MACHINE`

**Workaround:** Use extraction feature and manually deploy files to user-accessible locations.

### Large MSI Files
Very large MSI files (>500 MB) may take several minutes to extract:
- Be patient during extraction
- Monitor the status window/message
- Consider using a faster storage device

### MSI Extraction to Network Drives
Extracting to network drives may fail with some MSI packages:
- Use local drives when possible
- Test with network drives if needed for your use case

## ✅ Test Completion Checklist

Before considering testing complete, verify:

- [ ] Automated verification script passes all tests
- [ ] At least one real MSI file successfully extracted
- [ ] readmeINSTALL.html generates correctly
- [ ] File structure matches original MSI intent
- [ ] Non-admin installation attempted (success or graceful failure)
- [ ] Windows Desktop App tested
- [ ] Web Application tested
- [ ] Error handling verified for both apps
- [ ] Documentation reviewed and accurate
- [ ] Test results documented

## 🎓 Advanced Testing Scenarios

### Testing with Various MSI Types

Test with different types of MSI files:
1. **Simple MSI** - Basic file installer (e.g., simple utility app)
2. **Complex MSI** - Multi-component installer (e.g., office suite)
3. **Driver MSI** - Hardware driver installer (may require admin)
4. **Service MSI** - Windows service installer (likely requires admin)

### Performance Testing

1. **Small MSI (< 10 MB)**
   - Measure extraction time
   - Verify quick processing

2. **Medium MSI (10-100 MB)**
   - Measure extraction time
   - Verify reasonable performance

3. **Large MSI (> 100 MB)**
   - Measure extraction time
   - Verify no timeout issues

### Stress Testing

1. Extract 10 different MSI files in succession
2. Verify no memory leaks
3. Verify temp file cleanup
4. Verify consistent performance

## 📞 Reporting Issues

If you encounter issues during testing:

1. **Document the issue:**
   - MSI file name and size
   - Error message or unexpected behavior
   - Steps to reproduce
   - Screenshots if applicable

2. **Check logs:**
   - Windows Event Viewer (Application logs)
   - MSI installation logs (`%TEMP%\MSI*.log`)

3. **Collect information:**
   - OS version
   - .NET version
   - User privilege level
   - Antivirus software (may interfere)

## 🎯 Test Success Criteria

Testing is considered successful when:

1. ✅ Automated verification shows 80%+ success rate
2. ✅ At least one real MSI extracts successfully
3. ✅ readmeINSTALL.html generates with complete information
4. ✅ Non-admin installation works OR fails gracefully with clear messaging
5. ✅ Both Desktop and Web apps function correctly
6. ✅ No unhandled exceptions or crashes
7. ✅ Extracted files are complete and usable

## 📚 Additional Resources

- [Microsoft Docs: msiexec command-line options](https://learn.microsoft.com/windows/win32/msi/command-line-options)
- [Windows Installer Error Codes](https://learn.microsoft.com/windows/win32/msi/error-codes)
- [Per-User Installation Guidelines](https://learn.microsoft.com/windows/win32/msi/installation-context)
- [WiX Toolset](https://wixtoolset.org/) - For creating test MSI files

## 🏁 Conclusion

Following this testing guide ensures that the METAinstallNOADMIN applications work correctly and can reliably extract and install MSI packages without administrator privileges. The verification scripts automate much of the testing, but manual testing is still important to verify the user experience.

For questions or issues, please refer to the main [README.md](README.md) and [USAGE.md](USAGE.md) files.
