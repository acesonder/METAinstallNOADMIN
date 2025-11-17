# Quick Start - Testing Guide

🚀 **Fast track to verifying METAinstallNOADMIN functionality**

## ⚡ 30-Second Quick Test

Got an MSI file? Run this:

```cmd
Test-MSI.bat "C:\path\to\your.msi"
```

That's it! The script will:
- Extract the MSI
- Count files
- Generate readme
- Open results

---

## 🎯 Choose Your Testing Style

### 1️⃣ I Just Want It to Work (Beginner)

**Using Batch File:**
```cmd
Test-MSI.bat "C:\Downloads\MyApp.msi"
```

**Using Windows Desktop App:**
```powershell
cd WindowsApp
dotnet run
```
Then click buttons in the GUI. Easy!

### 2️⃣ I Want Detailed Reports (Intermediate)

**Test a specific application:**
```powershell
.\Test-SpecificMSI.ps1 -MsiPath "C:\path\to\WorldCreator.msi" -AppName "WorldCreator"
```

**Extract only (safe, no installation):**
```powershell
.\Test-SpecificMSI.ps1 -MsiPath "C:\path\to\app.msi" -ExtractOnly
```

### 3️⃣ I Want Full Automated Testing (Advanced)

**Without MSI (structure check only):**
```powershell
.\Verify-MSIExtraction.ps1
```

**With MSI (full test suite):**
```powershell
.\Verify-MSIExtraction.ps1 -TestMsiPath "C:\path\to\test.msi"
```

---

## 📝 Testing World Creator Specifically

If you have World Creator MSI:

```powershell
# Safe test - extract only
.\Test-SpecificMSI.ps1 -MsiPath "C:\Downloads\WorldCreator.msi" -AppName "WorldCreator" -ExtractOnly

# Full test - extract + optional install
.\Test-SpecificMSI.ps1 -MsiPath "C:\Downloads\WorldCreator.msi" -AppName "WorldCreator"
```

The script will:
1. ✅ Extract all World Creator files
2. 📊 Show detailed statistics
3. 📄 Generate beautiful HTML report
4. 🌐 Open report in browser
5. ❓ Ask if you want to try installation

---

## 🌐 Testing the Web Application

```powershell
cd WebApp
dotnet run
```

Then open: **https://localhost:5001**

1. Click "Choose File"
2. Select an MSI
3. Click "Extract MSI Contents"
4. Click "View Installation Guide"

---

## 🎮 Testing the Desktop Application

```powershell
cd WindowsApp
dotnet run
```

1. Click "Browse..." for MSI
2. Select your MSI file
3. Click "Extract MSI Contents"
4. Check the output folder

---

## 🆘 Common Issues

### "Script execution is disabled"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "msiexec is not recognized"
You're not on Windows. These tools only work on Windows.

### "MSI extraction failed"
Some MSI files are protected or encrypted. Try a different MSI file.

### ".NET not found"
Install .NET 10.0 SDK: https://dotnet.microsoft.com/download

---

## 📊 What Success Looks Like

### ✅ Successful Extraction
```
✓ Extraction completed successfully!
  Duration: 3.2 seconds
  Files extracted: 245
  Total size: 156.7 MB
✓ readmeINSTALL.html generated
```

### ✅ Successful Installation
```
✓ Installation completed successfully!
  Duration: 8.5 seconds
Application installed for user: YourUsername
```

### ⚠️ Expected Failures
Some MSI files **cannot** be installed without admin:
```
✗ Installation failed with exit code: 1603
  This MSI may require administrator privileges.
  Consider using the extracted files for manual installation.
```
👉 This is normal! Use the extracted files instead.

---

## 🎯 Which Test Should I Use?

| Situation | Use This |
|-----------|----------|
| Just want to extract | `Test-MSI.bat` |
| Want detailed report | `Test-SpecificMSI.ps1` |
| Testing World Creator | `Test-SpecificMSI.ps1` with `-AppName "WorldCreator"` |
| Want to test installation | `Test-SpecificMSI.ps1` (without `-ExtractOnly`) |
| Want full validation | `Verify-MSIExtraction.ps1` |
| Prefer GUI | `cd WindowsApp && dotnet run` |
| Need web interface | `cd WebApp && dotnet run` |

---

## 📖 More Information

- **Detailed testing guide**: See [TESTING.md](TESTING.md)
- **Usage instructions**: See [USAGE.md](USAGE.md)
- **Build instructions**: See [BUILD.md](BUILD.md)
- **Main documentation**: See [README.md](README.md)

---

## 💡 Pro Tips

1. **Test with simple MSI first** - Don't start with World Creator
2. **Use -ExtractOnly** - Safer for initial testing
3. **Review the HTML report** - It shows exactly what's in the MSI
4. **Check extraction folder** - Verify files look correct
5. **Installation may fail** - That's OK! Extraction still works

---

## 🎉 You're Ready!

Pick a testing method above and run it. The scripts are designed to be self-explanatory and will guide you through the process.

**Questions?** Check [TESTING.md](TESTING.md) for detailed information.
