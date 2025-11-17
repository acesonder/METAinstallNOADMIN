# Test-SpecificMSI.ps1
# Test a specific MSI file with both WindowsApp and WebApp approaches
# Specifically designed for testing apps like World Creator

param(
    [Parameter(Mandatory=$true)]
    [string]$MsiPath,
    
    [Parameter(Mandatory=$false)]
    [string]$AppName = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipInstall,
    
    [Parameter(Mandatory=$false)]
    [switch]$ExtractOnly
)

# Validate MSI file exists
if (-not (Test-Path $MsiPath)) {
    Write-Host "ERROR: MSI file not found: $MsiPath" -ForegroundColor Red
    exit 1
}

# Get app name from MSI filename if not provided
if (-not $AppName) {
    $AppName = [System.IO.Path]::GetFileNameWithoutExtension($MsiPath)
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Testing MSI: $AppName" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "MSI File: $MsiPath" -ForegroundColor White
Write-Host ""

# Create output directory
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outputBase = "$env:USERPROFILE\Documents\MSI_Tests"
$extractPath = Join-Path $outputBase "${AppName}_Extract_$timestamp"

Write-Host "Creating output directory..." -ForegroundColor Yellow
New-Item -Path $extractPath -ItemType Directory -Force | Out-Null
Write-Host "✓ Output directory: $extractPath" -ForegroundColor Green
Write-Host ""

# Test 1: Extract MSI Contents
Write-Host "────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "TEST 1: Extracting MSI Contents" -ForegroundColor Cyan
Write-Host "────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host ""

Write-Host "Running: msiexec.exe /a `"$MsiPath`" /qn TARGETDIR=`"$extractPath`"" -ForegroundColor Gray
Write-Host "Please wait, this may take a few moments..." -ForegroundColor Yellow
Write-Host ""

$extractStart = Get-Date
$extractProcess = Start-Process -FilePath "msiexec.exe" `
                                -ArgumentList "/a `"$MsiPath`" /qn TARGETDIR=`"$extractPath`"" `
                                -Wait -PassThru -NoNewWindow

$extractDuration = (Get-Date) - $extractStart
$extractExitCode = $extractProcess.ExitCode

if ($extractExitCode -eq 0) {
    Write-Host "✓ Extraction completed successfully!" -ForegroundColor Green
    Write-Host "  Duration: $($extractDuration.TotalSeconds) seconds" -ForegroundColor Gray
    Write-Host ""
    
    # Analyze extracted content
    Write-Host "Analyzing extracted content..." -ForegroundColor Yellow
    $files = Get-ChildItem -Path $extractPath -Recurse -File -ErrorAction SilentlyContinue
    $folders = Get-ChildItem -Path $extractPath -Recurse -Directory -ErrorAction SilentlyContinue
    
    $totalSize = ($files | Measure-Object -Property Length -Sum).Sum
    $totalSizeMB = [math]::Round($totalSize / 1MB, 2)
    
    Write-Host ""
    Write-Host "Extraction Summary:" -ForegroundColor Cyan
    Write-Host "  Total Files:   $($files.Count)" -ForegroundColor White
    Write-Host "  Total Folders: $($folders.Count)" -ForegroundColor White
    Write-Host "  Total Size:    $totalSizeMB MB" -ForegroundColor White
    Write-Host ""
    
    # Show file type distribution
    $fileTypes = $files | Group-Object Extension | Sort-Object Count -Descending | Select-Object -First 10
    Write-Host "Top File Types:" -ForegroundColor Cyan
    foreach ($type in $fileTypes) {
        $ext = if ($type.Name) { $type.Name } else { "(no extension)" }
        $size = ($type.Group | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Host ("  {0,-15} {1,5} files  ({2,8:N2} MB)" -f $ext, $type.Count, $size) -ForegroundColor White
    }
    Write-Host ""
    
    # Generate readmeINSTALL.html
    Write-Host "Generating readmeINSTALL.html..." -ForegroundColor Yellow
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset='UTF-8'>
    <title>$AppName - MSI Installation Guide</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
        .container { max-width: 1200px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 10px 40px rgba(0,0,0,0.3); }
        h1 { color: #333; border-bottom: 3px solid #667eea; padding-bottom: 15px; margin-top: 0; }
        h2 { color: #667eea; margin-top: 30px; }
        .info { background: linear-gradient(135deg, #667eea20 0%, #764ba220 100%); padding: 15px; border-left: 5px solid #667eea; margin: 15px 0; border-radius: 5px; }
        .success { background-color: #d4edda; border-left: 5px solid #28a745; color: #155724; padding: 15px; margin: 15px 0; border-radius: 5px; }
        .file-tree { background-color: #f8f9fa; padding: 20px; border-radius: 5px; font-family: 'Consolas', monospace; font-size: 14px; max-height: 600px; overflow-y: auto; }
        .folder { color: #667eea; font-weight: bold; margin-top: 8px; }
        .file { color: #333; margin-left: 20px; padding: 2px 0; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin: 20px 0; }
        .stat-card { background: linear-gradient(135deg, #667eea10 0%, #764ba210 100%); padding: 20px; border-radius: 8px; text-align: center; border: 2px solid #667eea30; }
        .stat-value { font-size: 32px; font-weight: bold; color: #667eea; }
        .stat-label { color: #666; margin-top: 5px; }
        code { background-color: #f4f4f4; padding: 2px 6px; border-radius: 3px; font-family: 'Consolas', monospace; }
        .note { background-color: #fff3cd; border-left: 5px solid #ffc107; color: #856404; padding: 15px; margin: 15px 0; border-radius: 5px; }
    </style>
</head>
<body>
    <div class='container'>
        <h1>📦 $AppName - Installation Guide</h1>
        
        <div class='success'>
            <strong>✓ MSI Extraction Completed Successfully!</strong>
        </div>
        
        <div class='info'>
            <strong>📅 Extraction Date:</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')<br>
            <strong>📁 Extract Location:</strong> <code>$extractPath</code><br>
            <strong>⏱️ Duration:</strong> $($extractDuration.TotalSeconds) seconds
        </div>
        
        <h2>📊 Extraction Statistics</h2>
        <div class='stats'>
            <div class='stat-card'>
                <div class='stat-value'>$($files.Count)</div>
                <div class='stat-label'>Files Extracted</div>
            </div>
            <div class='stat-card'>
                <div class='stat-value'>$($folders.Count)</div>
                <div class='stat-label'>Folders Created</div>
            </div>
            <div class='stat-card'>
                <div class='stat-value'>$totalSizeMB MB</div>
                <div class='stat-label'>Total Size</div>
            </div>
        </div>
        
        <h2>📂 File and Folder Structure</h2>
        <div class='file-tree'>
"@
    
    # Add file tree (limited to first 100 items for performance)
    $itemCount = 0
    $maxItems = 100
    
    function Add-FileTreeItem {
        param($Path, $Level, [ref]$Html, [ref]$Count)
        
        if ($Count.Value -ge $maxItems) { return }
        
        $items = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue | Sort-Object { $_.PSIsContainer } -Descending
        
        foreach ($item in $items) {
            if ($Count.Value -ge $maxItems) { break }
            
            $indent = $Level * 20
            $name = $item.Name
            
            if ($item.PSIsContainer) {
                $Html.Value += "            <div class='folder' style='margin-left: ${indent}px;'>📁 $name/</div>`n"
                $Count.Value++
                Add-FileTreeItem -Path $item.FullName -Level ($Level + 1) -Html $Html -Count $Count
            } else {
                if ($name -ne "readmeINSTALL.html") {
                    $size = if ($item.Length -lt 1KB) { "$($item.Length) B" } 
                           elseif ($item.Length -lt 1MB) { "{0:N2} KB" -f ($item.Length / 1KB) }
                           else { "{0:N2} MB" -f ($item.Length / 1MB) }
                    $Html.Value += "            <div class='file' style='margin-left: ${indent}px;'>📄 $name <span style='color: #999;'>($size)</span></div>`n"
                    $Count.Value++
                }
            }
        }
    }
    
    $htmlRef = [ref]$html
    $countRef = [ref]$itemCount
    Add-FileTreeItem -Path $extractPath -Level 0 -Html $htmlRef -Count $countRef
    $html = $htmlRef.Value
    
    if ($files.Count -gt $maxItems) {
        $html += "            <div class='note'>... and $($files.Count - $maxItems) more items (showing first $maxItems for performance)</div>`n"
    }
    
    $html += @"
        </div>
        
        <h2>🚀 Installation Instructions</h2>
        
        <div class='note'>
            <strong>⚠️ Important:</strong> This extraction was performed using <code>msiexec /a</code> which does not require administrator privileges.
        </div>
        
        <div class='info'>
            <h3>Standard Installation Paths:</h3>
            <ul>
                <li><strong>Program Files:</strong> <code>C:\Program Files\$AppName\</code> (requires admin)</li>
                <li><strong>Program Files (x86):</strong> <code>C:\Program Files (x86)\$AppName\</code> (requires admin)</li>
            </ul>
            
            <h3>Non-Admin Installation Alternatives:</h3>
            <ul>
                <li><strong>Recommended:</strong> <code>%LOCALAPPDATA%\Programs\$AppName\</code></li>
                <li><strong>Alternative:</strong> <code>%USERPROFILE%\$AppName\</code></li>
                <li><strong>Alternative:</strong> <code>%APPDATA%\$AppName\</code></li>
            </ul>
        </div>
        
        <h2>🔧 Manual Installation Steps</h2>
        <div class='info'>
            <ol>
                <li>Copy the extracted files to your desired location (e.g., <code>%LOCALAPPDATA%\Programs\$AppName\</code>)</li>
                <li>Create a shortcut to the main executable on your desktop or start menu</li>
                <li>If configuration files exist, ensure they point to the correct paths</li>
                <li>Update PATH environment variable if needed (user-level only)</li>
            </ol>
        </div>
        
        <h2>🔐 Per-User Installation (No Admin)</h2>
        <div class='info'>
            <p>To install this MSI for the current user without admin privileges, use:</p>
            <code style='display: block; padding: 10px; background-color: #2d2d2d; color: #f8f8f2; border-radius: 5px; margin: 10px 0;'>
                msiexec.exe /i "$MsiPath" ALLUSERS=2 MSIINSTALLPERUSER=1 /qb
            </code>
            <p><strong>Flags explained:</strong></p>
            <ul>
                <li><code>ALLUSERS=2</code> - Enables per-user installation</li>
                <li><code>MSIINSTALLPERUSER=1</code> - Forces per-user context</li>
                <li><code>/qb</code> - Shows basic UI during installation</li>
            </ul>
        </div>
        
        <div class='note'>
            <strong>📝 Note:</strong> Some MSI packages may have hardcoded admin requirements. If installation fails, manual file deployment is your best option.
        </div>
        
        <h2>✅ Verification</h2>
        <div class='success'>
            This extraction and documentation were automatically generated by <strong>METAinstallNOADMIN</strong><br>
            Tested on: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')<br>
            System: $env:COMPUTERNAME ($env:USERNAME)
        </div>
    </div>
</body>
</html>
"@
    
    $readmePath = Join-Path $extractPath "readmeINSTALL.html"
    Set-Content -Path $readmePath -Value $html -Encoding UTF8
    
    Write-Host "✓ readmeINSTALL.html generated: $readmePath" -ForegroundColor Green
    Write-Host ""
    
    # Open the readme in browser
    Write-Host "Opening readmeINSTALL.html in default browser..." -ForegroundColor Yellow
    Start-Process $readmePath
    
} else {
    Write-Host "✗ Extraction failed with exit code: $extractExitCode" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common reasons for failure:" -ForegroundColor Yellow
    Write-Host "  - MSI file is corrupted" -ForegroundColor Gray
    Write-Host "  - MSI requires special permissions" -ForegroundColor Gray
    Write-Host "  - Target directory is not writable" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Test 2: Test Installation (if not skipped)
if (-not $SkipInstall -and -not $ExtractOnly) {
    Write-Host ""
    Write-Host "────────────────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host "TEST 2: Per-User Installation (No Admin)" -ForegroundColor Cyan
    Write-Host "────────────────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host ""
    
    $response = Read-Host "Do you want to attempt per-user installation? This will install $AppName on your system. (y/N)"
    
    if ($response -eq 'y' -or $response -eq 'Y') {
        Write-Host ""
        Write-Host "Running: msiexec.exe /i `"$MsiPath`" ALLUSERS=2 MSIINSTALLPERUSER=1 /qb" -ForegroundColor Gray
        Write-Host "A Windows Installer dialog may appear. Please wait..." -ForegroundColor Yellow
        Write-Host ""
        
        $installStart = Get-Date
        $installProcess = Start-Process -FilePath "msiexec.exe" `
                                        -ArgumentList "/i `"$MsiPath`" ALLUSERS=2 MSIINSTALLPERUSER=1 /qb" `
                                        -Wait -PassThru -NoNewWindow
        
        $installDuration = (Get-Date) - $installStart
        $installExitCode = $installProcess.ExitCode
        
        Write-Host ""
        if ($installExitCode -eq 0) {
            Write-Host "✓ Installation completed successfully!" -ForegroundColor Green
            Write-Host "  Duration: $($installDuration.TotalSeconds) seconds" -ForegroundColor Gray
            Write-Host ""
            Write-Host "Application should now be installed for user: $env:USERNAME" -ForegroundColor Green
            Write-Host "Check Start Menu or installation directories for the application." -ForegroundColor Gray
        } elseif ($installExitCode -eq 1602) {
            Write-Host "⚠ Installation canceled by user." -ForegroundColor Yellow
        } elseif ($installExitCode -eq 1603) {
            Write-Host "✗ Installation failed: Fatal error during installation." -ForegroundColor Red
            Write-Host "  This MSI may require administrator privileges." -ForegroundColor Yellow
            Write-Host "  Consider using the extracted files for manual installation." -ForegroundColor Yellow
        } else {
            Write-Host "✗ Installation failed with exit code: $installExitCode" -ForegroundColor Red
            Write-Host "  See Windows Installer error codes for details." -ForegroundColor Gray
            Write-Host "  You can still use the extracted files for manual installation." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Installation skipped by user." -ForegroundColor Yellow
    }
} else {
    if ($ExtractOnly) {
        Write-Host "Installation skipped (ExtractOnly mode)." -ForegroundColor Yellow
    } else {
        Write-Host "Installation skipped (SkipInstall flag)." -ForegroundColor Yellow
    }
}

# Final Summary
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Test Complete!" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Results saved to: $extractPath" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Review the readmeINSTALL.html file for detailed information" -ForegroundColor White
Write-Host "  2. Examine the extracted files to understand the application structure" -ForegroundColor White
Write-Host "  3. Test manual installation if needed" -ForegroundColor White
Write-Host ""
