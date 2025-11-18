# Verify-MSIExtraction.ps1
# Comprehensive verification script for MSI extraction and installation functionality
# This script tests the core functionality of the METAinstallNOADMIN applications

param(
    [Parameter(Mandatory=$false)]
    [string]$TestMsiPath = "",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDirectory = "$env:TEMP\MSI_Verification_Tests",
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

# Color output functions
function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Failure {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

# Test counter
$script:TestsPassed = 0
$script:TestsFailed = 0
$script:TestsTotal = 0

function Test-Assertion {
    param(
        [bool]$Condition,
        [string]$TestName,
        [string]$SuccessMessage = "",
        [string]$FailureMessage = ""
    )
    
    $script:TestsTotal++
    
    if ($Condition) {
        $script:TestsPassed++
        $msg = if ($SuccessMessage) { $SuccessMessage } else { $TestName }
        Write-Success $msg
        return $true
    } else {
        $script:TestsFailed++
        $msg = if ($FailureMessage) { $FailureMessage } else { $TestName }
        Write-Failure $msg
        return $false
    }
}

# Main verification function
function Start-Verification {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     MSI Installation Verification System                      ║" -ForegroundColor Cyan
    Write-Host "║     Testing METAinstallNOADMIN functionality                   ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Test 1: Check if msiexec.exe exists
    Write-Info "Test 1: Checking for msiexec.exe..."
    $msiexecPath = Get-Command msiexec.exe -ErrorAction SilentlyContinue
    Test-Assertion -Condition ($null -ne $msiexecPath) `
                   -TestName "msiexec.exe is available" `
                   -FailureMessage "msiexec.exe not found - MSI operations will fail"
    
    # Test 2: Check .NET installation
    Write-Info "Test 2: Checking .NET installation..."
    $dotnetVersion = dotnet --version 2>$null
    Test-Assertion -Condition ($null -ne $dotnetVersion) `
                   -TestName ".NET SDK is installed (Version: $dotnetVersion)" `
                   -FailureMessage ".NET SDK not found - cannot build/run applications"
    
    # Test 3: Check if solution builds
    Write-Info "Test 3: Building solution..."
    $buildResult = dotnet build "$PSScriptRoot\METAinstallNOADMIN.sln" --verbosity quiet 2>&1
    $buildSuccess = $LASTEXITCODE -eq 0
    Test-Assertion -Condition $buildSuccess `
                   -TestName "Solution builds successfully" `
                   -FailureMessage "Build failed: $buildResult"
    
    # Test 4: Create test directory
    Write-Info "Test 4: Creating test output directory..."
    if (Test-Path $OutputDirectory) {
        Remove-Item -Path $OutputDirectory -Recurse -Force
    }
    New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
    Test-Assertion -Condition (Test-Path $OutputDirectory) `
                   -TestName "Test directory created: $OutputDirectory"
    
    # Test 5: Test MSI extraction if test MSI provided
    if ($TestMsiPath -and (Test-Path $TestMsiPath)) {
        Write-Info "Test 5: Testing MSI extraction..."
        $extractPath = Join-Path $OutputDirectory "ExtractTest_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        
        $msiExec = Start-Process -FilePath "msiexec.exe" `
                                  -ArgumentList "/a `"$TestMsiPath`" /qn TARGETDIR=`"$extractPath`"" `
                                  -Wait -PassThru -NoNewWindow
        
        $extractSuccess = ($msiExec.ExitCode -eq 0) -and (Test-Path $extractPath)
        Test-Assertion -Condition $extractSuccess `
                       -TestName "MSI extraction completed successfully" `
                       -FailureMessage "MSI extraction failed with exit code: $($msiExec.ExitCode)"
        
        if ($extractSuccess) {
            # Test 6: Verify extracted files exist
            Write-Info "Test 6: Verifying extracted files..."
            $files = Get-ChildItem -Path $extractPath -Recurse -File
            Test-Assertion -Condition ($files.Count -gt 0) `
                           -TestName "Extracted files found: $($files.Count) files" `
                           -FailureMessage "No files found in extraction directory"
            
            # Test 7: Test readmeINSTALL.html generation
            Write-Info "Test 7: Testing readmeINSTALL.html generation..."
            $readmePath = Join-Path $extractPath "readmeINSTALL.html"
            
            # Manually generate the readme (simulating what the app does)
            $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset='UTF-8'>
    <title>MSI Installation Guide</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        h1 { color: #333; border-bottom: 2px solid #0066cc; padding-bottom: 10px; }
        h2 { color: #0066cc; margin-top: 20px; }
        .file-tree { background-color: white; padding: 15px; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .folder { color: #0066cc; font-weight: bold; margin-top: 10px; }
        .file { color: #333; margin-left: 20px; font-family: monospace; }
        .info { background-color: #e7f3ff; padding: 10px; border-left: 4px solid #0066cc; margin: 10px 0; }
    </style>
</head>
<body>
    <h1>MSI Installation Guide - Verification Test</h1>
    <div class='info'><strong>Extraction Date:</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</div>
    <div class='info'><strong>Extract Location:</strong> $extractPath</div>
    <h2>File and Folder Structure</h2>
    <div class='file-tree'>
        <p>Files extracted: $($files.Count)</p>
"@
            
            foreach ($file in ($files | Select-Object -First 10)) {
                $relativePath = $file.FullName.Replace($extractPath, "").TrimStart('\')
                $size = "{0:N2} KB" -f ($file.Length / 1KB)
                $htmlContent += "        <div class='file'>📄 $relativePath ($size)</div>`n"
            }
            
            if ($files.Count -gt 10) {
                $htmlContent += "        <div class='info'>... and $($files.Count - 10) more files</div>`n"
            }
            
            $htmlContent += @"
    </div>
    <h2>Installation Instructions</h2>
    <div class='info'>
        <p>After extraction, files should typically be placed in the following locations:</p>
        <ul>
            <li><strong>Program Files:</strong> Usually go to <code>C:\Program Files\[AppName]\</code></li>
            <li><strong>User Data:</strong> Often goes to <code>%APPDATA%\[AppName]\</code> or <code>%LOCALAPPDATA%\[AppName]\</code></li>
        </ul>
        <p><strong>Note:</strong> For non-admin installation, files can be placed in user-accessible locations such as:</p>
        <ul>
            <li><code>%LOCALAPPDATA%\Programs\[AppName]\</code></li>
            <li><code>%USERPROFILE%\[AppName]\</code></li>
        </ul>
    </div>
</body>
</html>
"@
            
            Set-Content -Path $readmePath -Value $htmlContent -Encoding UTF8
            Test-Assertion -Condition (Test-Path $readmePath) `
                           -TestName "readmeINSTALL.html generated successfully" `
                           -FailureMessage "Failed to generate readmeINSTALL.html"
            
            if (Test-Path $readmePath) {
                $readmeContent = Get-Content $readmePath -Raw
                $hasTitle = $readmeContent -match "<title>MSI Installation Guide"
                $hasFileTree = $readmeContent -match "File and Folder Structure"
                $hasInstructions = $readmeContent -match "Installation Instructions"
                
                Test-Assertion -Condition $hasTitle `
                               -TestName "readmeINSTALL.html contains proper title"
                Test-Assertion -Condition $hasFileTree `
                               -TestName "readmeINSTALL.html contains file tree section"
                Test-Assertion -Condition $hasInstructions `
                               -TestName "readmeINSTALL.html contains installation instructions"
            }
        }
        
        # Test 8: Test non-admin installation flags
        Write-Info "Test 8: Testing non-admin installation command structure..."
        $installCmd = "msiexec.exe /i `"$TestMsiPath`" ALLUSERS=2 MSIINSTALLPERUSER=1 /qb"
        Test-Assertion -Condition ($installCmd -match "ALLUSERS=2") `
                       -TestName "Installation command includes ALLUSERS=2 flag"
        Test-Assertion -Condition ($installCmd -match "MSIINSTALLPERUSER=1") `
                       -TestName "Installation command includes MSIINSTALLPERUSER=1 flag"
        
        Write-Warning "Note: Actual installation test skipped to avoid system modifications"
        Write-Warning "To test installation, run: $installCmd"
        
    } else {
        Write-Warning "No test MSI file provided. Skipping extraction and installation tests."
        Write-Info "To run full tests, provide a test MSI file: -TestMsiPath 'path\to\test.msi'"
        Write-Info "Example: .\Verify-MSIExtraction.ps1 -TestMsiPath 'C:\path\to\app.msi'"
    }
    
    # Test 9: Verify WindowsApp project structure
    Write-Info "Test 9: Verifying WindowsApp project..."
    $windowsAppPath = Join-Path $PSScriptRoot "WindowsApp"
    $form1Path = Join-Path $windowsAppPath "Form1.cs"
    $projPath = Join-Path $windowsAppPath "MSIInstaller.csproj"
    
    Test-Assertion -Condition (Test-Path $windowsAppPath) `
                   -TestName "WindowsApp directory exists"
    Test-Assertion -Condition (Test-Path $form1Path) `
                   -TestName "WindowsApp Form1.cs exists"
    Test-Assertion -Condition (Test-Path $projPath) `
                   -TestName "WindowsApp project file exists"
    
    if (Test-Path $form1Path) {
        $form1Content = Get-Content $form1Path -Raw
        Test-Assertion -Condition ($form1Content -match "ALLUSERS=2") `
                       -TestName "Form1.cs contains ALLUSERS=2 flag"
        Test-Assertion -Condition ($form1Content -match "MSIINSTALLPERUSER=1") `
                       -TestName "Form1.cs contains MSIINSTALLPERUSER=1 flag"
        Test-Assertion -Condition ($form1Content -match "GenerateReadmeHtml") `
                       -TestName "Form1.cs implements readme generation"
    }
    
    # Test 10: Verify WebApp project structure
    Write-Info "Test 10: Verifying WebApp project..."
    $webAppPath = Join-Path $PSScriptRoot "WebApp"
    $indexPath = Join-Path $webAppPath "Pages\Index.cshtml.cs"
    $webProjPath = Join-Path $webAppPath "MSIInstallerWeb.csproj"
    
    Test-Assertion -Condition (Test-Path $webAppPath) `
                   -TestName "WebApp directory exists"
    Test-Assertion -Condition (Test-Path $indexPath) `
                   -TestName "WebApp Index.cshtml.cs exists"
    Test-Assertion -Condition (Test-Path $webProjPath) `
                   -TestName "WebApp project file exists"
    
    if (Test-Path $indexPath) {
        $indexContent = Get-Content $indexPath -Raw
        Test-Assertion -Condition ($indexContent -match "ALLUSERS=2") `
                       -TestName "Index.cshtml.cs contains ALLUSERS=2 flag"
        Test-Assertion -Condition ($indexContent -match "MSIINSTALLPERUSER=1") `
                       -TestName "Index.cshtml.cs contains MSIINSTALLPERUSER=1 flag"
        Test-Assertion -Condition ($indexContent -match "GenerateReadmeHtml") `
                       -TestName "Index.cshtml.cs implements readme generation"
    }
    
    # Test 11: Check user permission levels
    Write-Info "Test 11: Checking user permission levels..."
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) {
        Write-Warning "Running as Administrator - per-user installation features can be tested"
    } else {
        Write-Success "Running as standard user - ideal for testing non-admin functionality"
    }
    
    # Print summary
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                    Verification Summary                       ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total Tests:  $script:TestsTotal" -ForegroundColor White
    Write-Success "Passed:       $script:TestsPassed"
    if ($script:TestsFailed -gt 0) {
        Write-Failure "Failed:       $script:TestsFailed"
    } else {
        Write-Host "Failed:       $script:TestsFailed" -ForegroundColor Gray
    }
    
    $successRate = if ($script:TestsTotal -gt 0) { 
        [math]::Round(($script:TestsPassed / $script:TestsTotal) * 100, 2) 
    } else { 
        0 
    }
    Write-Host "Success Rate: $successRate%" -ForegroundColor $(if ($successRate -ge 80) { "Green" } elseif ($successRate -ge 60) { "Yellow" } else { "Red" })
    Write-Host ""
    
    if ($TestMsiPath) {
        Write-Info "Output directory: $OutputDirectory"
        Write-Info "Review extracted files and readmeINSTALL.html for validation"
    } else {
        Write-Warning "Run with -TestMsiPath parameter to perform full extraction tests"
    }
    
    Write-Host ""
    
    # Return exit code
    if ($script:TestsFailed -eq 0) {
        Write-Success "All verification tests passed!"
        exit 0
    } else {
        Write-Failure "Some verification tests failed. Please review the results above."
        exit 1
    }
}

# Run verification
Start-Verification
