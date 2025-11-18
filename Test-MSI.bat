@echo off
REM Test-MSI.bat
REM Simple batch script to test MSI extraction
REM For more advanced testing, use Test-SpecificMSI.ps1 or Verify-MSIExtraction.ps1

setlocal enabledelayedexpansion

echo.
echo ================================================================
echo   MSI Extraction Test - METAinstallNOADMIN
echo ================================================================
echo.

REM Check if MSI file was provided as argument
if "%~1"=="" (
    echo ERROR: No MSI file specified
    echo.
    echo Usage: Test-MSI.bat "path\to\file.msi"
    echo.
    echo Example: Test-MSI.bat "C:\Downloads\MyApp.msi"
    echo.
    pause
    exit /b 1
)

set "MSI_FILE=%~1"

REM Check if file exists
if not exist "%MSI_FILE%" (
    echo ERROR: MSI file not found: %MSI_FILE%
    echo.
    pause
    exit /b 1
)

REM Get file name without extension
for %%F in ("%MSI_FILE%") do set "APP_NAME=%%~nF"

REM Create output directory
set "OUTPUT_DIR=%USERPROFILE%\Documents\MSI_Extract_%APP_NAME%"
echo Creating output directory...
echo %OUTPUT_DIR%
echo.

if exist "%OUTPUT_DIR%" (
    echo Directory already exists. Contents will be replaced.
    rd /s /q "%OUTPUT_DIR%"
)
mkdir "%OUTPUT_DIR%"

REM Extract MSI
echo ----------------------------------------------------------------
echo Extracting MSI contents...
echo ----------------------------------------------------------------
echo.
echo MSI File: %MSI_FILE%
echo Target:   %OUTPUT_DIR%
echo.
echo Please wait, this may take a few moments...
echo.

msiexec.exe /a "%MSI_FILE%" /qn TARGETDIR="%OUTPUT_DIR%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ Extraction completed successfully!
    echo.
    
    REM Count files
    set FILE_COUNT=0
    for /r "%OUTPUT_DIR%" %%F in (*) do set /a FILE_COUNT+=1
    
    echo Extraction Summary:
    echo   Files extracted: !FILE_COUNT!
    echo   Location: %OUTPUT_DIR%
    echo.
    
    REM Create a simple readme
    echo ^<!DOCTYPE html^> > "%OUTPUT_DIR%\readmeINSTALL.html"
    echo ^<html^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo ^<head^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo     ^<meta charset='UTF-8'^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo     ^<title^>%APP_NAME% - Installation Guide^</title^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo     ^<style^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo         body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; } >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo         h1 { color: #333; border-bottom: 2px solid #0066cc; padding-bottom: 10px; } >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo         .info { background-color: #e7f3ff; padding: 10px; border-left: 4px solid #0066cc; margin: 10px 0; } >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo         .success { background-color: #d4edda; border-left: 4px solid #28a745; color: #155724; padding: 10px; margin: 10px 0; } >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo     ^</style^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo ^</head^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo ^<body^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo     ^<h1^>%APP_NAME% - Installation Guide^</h1^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo     ^<div class='success'^>^<strong^>✓ MSI Extraction Completed Successfully!^</strong^>^</div^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo     ^<div class='info'^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo         ^<strong^>Extraction Date:^</strong^> %DATE% %TIME%^<br^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo         ^<strong^>Extract Location:^</strong^> %OUTPUT_DIR%^<br^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo         ^<strong^>Files Extracted:^</strong^> !FILE_COUNT! >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo     ^</div^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo     ^<h2^>Installation Instructions^</h2^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo     ^<div class='info'^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo         ^<p^>Files can be manually installed to:^</p^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo         ^<ul^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo             ^<li^>^<code^>%%LOCALAPPDATA%%\Programs\%APP_NAME%\^</code^> (recommended)^</li^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo             ^<li^>^<code^>%%USERPROFILE%%\%APP_NAME%\^</code^>^</li^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo         ^</ul^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo     ^</div^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo     ^<h2^>Per-User Installation (No Admin)^</h2^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo     ^<div class='info'^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo         ^<p^>To install without admin privileges:^</p^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo         ^<code style='display: block; padding: 10px; background-color: #f0f0f0;'^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo             msiexec.exe /i "%MSI_FILE%" ALLUSERS=2 MSIINSTALLPERUSER=1 /qb >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo         ^</code^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo     ^</div^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo ^</body^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    echo ^</html^> >> "%OUTPUT_DIR%\readmeINSTALL.html"
    
    echo ✓ readmeINSTALL.html generated
    echo.
    
    REM Ask to open readme
    set /p OPEN="Open readmeINSTALL.html in browser? (Y/N): "
    if /i "!OPEN!"=="Y" (
        start "" "%OUTPUT_DIR%\readmeINSTALL.html"
    )
    
    REM Ask to open folder
    set /p OPEN_FOLDER="Open extraction folder? (Y/N): "
    if /i "!OPEN_FOLDER!"=="Y" (
        explorer "%OUTPUT_DIR%"
    )
    
) else (
    echo.
    echo ✗ Extraction failed with error code: %ERRORLEVEL%
    echo.
    echo Common reasons:
    echo   - MSI file is corrupted or invalid
    echo   - Target directory is not writable
    echo   - MSI requires special permissions
    echo.
)

echo.
echo ================================================================
echo   Test Complete
echo ================================================================
echo.
pause
