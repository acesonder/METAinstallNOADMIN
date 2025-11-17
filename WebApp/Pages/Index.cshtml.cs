using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Diagnostics;
using System.Text;

namespace MSIInstallerWeb.Pages;

public class IndexModel : PageModel
{
    private readonly IWebHostEnvironment _environment;
    private readonly ILogger<IndexModel> _logger;

    public string? StatusMessage { get; set; }
    public bool IsSuccess { get; set; }
    public string? ReadmePath { get; set; }
    public string DefaultExtractPath { get; set; } = string.Empty;

    public IndexModel(IWebHostEnvironment environment, ILogger<IndexModel> logger)
    {
        _environment = environment;
        _logger = logger;
    }

    public void OnGet()
    {
        // Set default extract path
        DefaultExtractPath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
            "MSI_Extract"
        );
    }

    public async Task<IActionResult> OnPostAsync(IFormFile? msiFile, string? extractPath, string action)
    {
        if (msiFile == null || msiFile.Length == 0)
        {
            StatusMessage = "Please select an MSI file.";
            IsSuccess = false;
            return Page();
        }

        if (!msiFile.FileName.EndsWith(".msi", StringComparison.OrdinalIgnoreCase))
        {
            StatusMessage = "Please select a valid MSI file.";
            IsSuccess = false;
            return Page();
        }

        // Save uploaded file to temp location
        string tempMsiPath = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString() + ".msi");
        
        try
        {
            using (var stream = new FileStream(tempMsiPath, FileMode.Create))
            {
                await msiFile.CopyToAsync(stream);
            }

            if (action == "install")
            {
                var result = await InstallMsiAsync(tempMsiPath);
                StatusMessage = result.Message;
                IsSuccess = result.Success;
            }
            else if (action == "extract")
            {
                // Use provided path or default
                string targetPath = string.IsNullOrWhiteSpace(extractPath) 
                    ? Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), 
                                   $"MSI_Extract_{Path.GetFileNameWithoutExtension(msiFile.FileName)}")
                    : extractPath;

                var result = await ExtractMsiAsync(tempMsiPath, targetPath);
                StatusMessage = result.Message;
                IsSuccess = result.Success;
                
                if (result.Success)
                {
                    ReadmePath = Path.Combine(targetPath, "readmeINSTALL.html");
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing MSI file");
            StatusMessage = $"Error: {ex.Message}";
            IsSuccess = false;
        }
        finally
        {
            // Clean up temp file
            try
            {
                if (System.IO.File.Exists(tempMsiPath))
                {
                    System.IO.File.Delete(tempMsiPath);
                }
            }
            catch { }
        }

        return Page();
    }

    public IActionResult OnGetViewReadme(string path)
    {
        if (System.IO.File.Exists(path))
        {
            var content = System.IO.File.ReadAllText(path);
            return Content(content, "text/html");
        }
        return NotFound();
    }

    private async Task<(bool Success, string Message)> InstallMsiAsync(string msiPath)
    {
        try
        {
            ProcessStartInfo psi = new ProcessStartInfo
            {
                FileName = "msiexec.exe",
                Arguments = $"/i \"{msiPath}\" ALLUSERS=2 MSIINSTALLPERUSER=1 /qb",
                UseShellExecute = false,
                CreateNoWindow = true,
                RedirectStandardOutput = true,
                RedirectStandardError = true
            };

            using Process? process = Process.Start(psi);
            if (process != null)
            {
                await process.WaitForExitAsync();

                if (process.ExitCode == 0)
                {
                    return (true, "Installation completed successfully! The application has been installed for the current user.");
                }
                else
                {
                    return (false, $"Installation failed with exit code: {process.ExitCode}. Some MSI files may require administrator privileges or have specific installation requirements.");
                }
            }
            
            return (false, "Failed to start installation process.");
        }
        catch (Exception ex)
        {
            return (false, $"Installation error: {ex.Message}");
        }
    }

    private async Task<(bool Success, string Message)> ExtractMsiAsync(string msiPath, string extractPath)
    {
        try
        {
            // Create extraction directory
            Directory.CreateDirectory(extractPath);

            ProcessStartInfo psi = new ProcessStartInfo
            {
                FileName = "msiexec.exe",
                Arguments = $"/a \"{msiPath}\" /qn TARGETDIR=\"{extractPath}\"",
                UseShellExecute = false,
                CreateNoWindow = true,
                RedirectStandardOutput = true,
                RedirectStandardError = true
            };

            using Process? process = Process.Start(psi);
            if (process != null)
            {
                string output = await process.StandardOutput.ReadToEndAsync();
                string error = await process.StandardError.ReadToEndAsync();

                await process.WaitForExitAsync();

                if (process.ExitCode == 0)
                {
                    // Generate readme file
                    GenerateReadmeHtml(extractPath);

                    return (true, $"<strong>Extraction completed successfully!</strong><br/>Files extracted to: <code>{extractPath}</code><br/>A readmeINSTALL.html file has been generated with installation details.");
                }
                else
                {
                    return (false, $"Extraction failed with exit code: {process.ExitCode}. Error: {error}");
                }
            }

            return (false, "Failed to start extraction process.");
        }
        catch (Exception ex)
        {
            return (false, $"Extraction error: {ex.Message}");
        }
    }

    private void GenerateReadmeHtml(string extractPath)
    {
        StringBuilder html = new StringBuilder();
        html.AppendLine("<!DOCTYPE html>");
        html.AppendLine("<html>");
        html.AppendLine("<head>");
        html.AppendLine("    <meta charset='UTF-8'>");
        html.AppendLine("    <title>MSI Installation Guide</title>");
        html.AppendLine("    <style>");
        html.AppendLine("        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }");
        html.AppendLine("        h1 { color: #333; border-bottom: 2px solid #0066cc; padding-bottom: 10px; }");
        html.AppendLine("        h2 { color: #0066cc; margin-top: 20px; }");
        html.AppendLine("        .file-tree { background-color: white; padding: 15px; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }");
        html.AppendLine("        .folder { color: #0066cc; font-weight: bold; margin-top: 10px; }");
        html.AppendLine("        .file { color: #333; margin-left: 20px; font-family: monospace; }");
        html.AppendLine("        .info { background-color: #e7f3ff; padding: 10px; border-left: 4px solid #0066cc; margin: 10px 0; }");
        html.AppendLine("    </style>");
        html.AppendLine("</head>");
        html.AppendLine("<body>");
        html.AppendLine("    <h1>MSI Installation Guide</h1>");
        html.AppendLine($"    <div class='info'><strong>Extraction Date:</strong> {DateTime.Now:yyyy-MM-dd HH:mm:ss}</div>");
        html.AppendLine($"    <div class='info'><strong>Extract Location:</strong> {extractPath}</div>");
        html.AppendLine("    <h2>File and Folder Structure</h2>");
        html.AppendLine("    <div class='file-tree'>");
        html.AppendLine("        <p>The following files and folders were extracted from the MSI package:</p>");

        // Recursively list all files and folders
        GenerateFileTree(extractPath, extractPath, html, 0);

        html.AppendLine("    </div>");
        html.AppendLine("    <h2>Installation Instructions</h2>");
        html.AppendLine("    <div class='info'>");
        html.AppendLine("        <p>After extraction, files should typically be placed in the following locations:</p>");
        html.AppendLine("        <ul>");
        html.AppendLine("            <li><strong>Program Files:</strong> Usually go to <code>C:\\Program Files\\[AppName]\\</code> or <code>C:\\Program Files (x86)\\[AppName]\\</code></li>");
        html.AppendLine("            <li><strong>User Data:</strong> Often goes to <code>%APPDATA%\\[AppName]\\</code> or <code>%LOCALAPPDATA%\\[AppName]\\</code></li>");
        html.AppendLine("            <li><strong>System Files:</strong> May need to be placed in <code>C:\\Windows\\System32\\</code> (requires admin)</li>");
        html.AppendLine("        </ul>");
        html.AppendLine("        <p><strong>Note:</strong> For non-admin installation, files can be placed in user-accessible locations such as:</p>");
        html.AppendLine("        <ul>");
        html.AppendLine("            <li><code>%LOCALAPPDATA%\\Programs\\[AppName]\\</code></li>");
        html.AppendLine("            <li><code>%USERPROFILE%\\[AppName]\\</code></li>");
        html.AppendLine("        </ul>");
        html.AppendLine("    </div>");
        html.AppendLine("</body>");
        html.AppendLine("</html>");

        string readmePath = Path.Combine(extractPath, "readmeINSTALL.html");
        System.IO.File.WriteAllText(readmePath, html.ToString());
    }

    private void GenerateFileTree(string rootPath, string currentPath, StringBuilder html, int level)
    {
        try
        {
            // Get directories
            var directories = Directory.GetDirectories(currentPath);
            foreach (var dir in directories)
            {
                string dirName = Path.GetFileName(dir);
                html.AppendLine($"        <div class='folder' style='margin-left: {level * 20}px;'>📁 {dirName}/</div>");
                GenerateFileTree(rootPath, dir, html, level + 1);
            }

            // Get files
            var files = Directory.GetFiles(currentPath);
            foreach (var file in files)
            {
                string fileName = Path.GetFileName(file);
                if (fileName == "readmeINSTALL.html") continue; // Skip the readme itself

                FileInfo fileInfo = new FileInfo(file);
                html.AppendLine($"        <div class='file' style='margin-left: {(level + 1) * 20}px;'>📄 {fileName} ({FormatFileSize(fileInfo.Length)})</div>");
            }
        }
        catch (UnauthorizedAccessException)
        {
            // Skip directories we can't access
        }
    }

    private string FormatFileSize(long bytes)
    {
        string[] sizes = { "B", "KB", "MB", "GB" };
        double len = bytes;
        int order = 0;
        while (len >= 1024 && order < sizes.Length - 1)
        {
            order++;
            len = len / 1024;
        }
        return $"{len:0.##} {sizes[order]}";
    }
}
