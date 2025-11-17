using System.Diagnostics;
using System.Text;

namespace MSIInstaller;

public partial class Form1 : Form
{
    public Form1()
    {
        InitializeComponent();
    }

    private void BtnBrowseMsi_Click(object? sender, EventArgs e)
    {
        using OpenFileDialog openFileDialog = new OpenFileDialog
        {
            Filter = "MSI Files (*.msi)|*.msi|All Files (*.*)|*.*",
            FilterIndex = 1,
            RestoreDirectory = true
        };

        if (openFileDialog.ShowDialog() == DialogResult.OK)
        {
            txtMsiPath.Text = openFileDialog.FileName;
            
            // Set default extract path
            string msiFileName = Path.GetFileNameWithoutExtension(openFileDialog.FileName);
            string defaultExtractPath = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
                $"MSI_Extract_{msiFileName}");
            txtExtractPath.Text = defaultExtractPath;
        }
    }

    private void BtnBrowseExtract_Click(object? sender, EventArgs e)
    {
        using FolderBrowserDialog folderBrowserDialog = new FolderBrowserDialog
        {
            Description = "Select folder to extract MSI contents",
            UseDescriptionForTitle = true
        };

        if (folderBrowserDialog.ShowDialog() == DialogResult.OK)
        {
            txtExtractPath.Text = folderBrowserDialog.SelectedPath;
        }
    }

    private async void BtnInstall_Click(object? sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtMsiPath.Text))
        {
            MessageBox.Show("Please select an MSI file first.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        if (!File.Exists(txtMsiPath.Text))
        {
            MessageBox.Show("The selected MSI file does not exist.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        btnInstall.Enabled = false;
        btnExtract.Enabled = false;
        txtStatus.Text = "Starting installation...\r\n";

        try
        {
            await Task.Run(() => InstallMsi(txtMsiPath.Text));
        }
        catch (Exception ex)
        {
            AppendStatus($"Error: {ex.Message}\r\n");
            MessageBox.Show($"Installation failed: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        finally
        {
            btnInstall.Enabled = true;
            btnExtract.Enabled = true;
        }
    }

    private async void BtnExtract_Click(object? sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtMsiPath.Text))
        {
            MessageBox.Show("Please select an MSI file first.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        if (!File.Exists(txtMsiPath.Text))
        {
            MessageBox.Show("The selected MSI file does not exist.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        if (string.IsNullOrWhiteSpace(txtExtractPath.Text))
        {
            MessageBox.Show("Please select an extraction folder.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        btnInstall.Enabled = false;
        btnExtract.Enabled = false;
        txtStatus.Text = "Starting extraction...\r\n";

        try
        {
            await Task.Run(() => ExtractMsi(txtMsiPath.Text, txtExtractPath.Text));
        }
        catch (Exception ex)
        {
            AppendStatus($"Error: {ex.Message}\r\n");
            MessageBox.Show($"Extraction failed: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        finally
        {
            btnInstall.Enabled = true;
            btnExtract.Enabled = true;
        }
    }

    private void InstallMsi(string msiPath)
    {
        AppendStatus($"Installing: {msiPath}\r\n");
        AppendStatus("Using per-user installation (no admin required)...\r\n");

        // Use msiexec with ALLUSERS=2 to install for current user only (no admin needed)
        ProcessStartInfo psi = new ProcessStartInfo
        {
            FileName = "msiexec.exe",
            Arguments = $"/i \"{msiPath}\" ALLUSERS=2 MSIINSTALLPERUSER=1 /qb",
            UseShellExecute = false,
            CreateNoWindow = false,
            RedirectStandardOutput = false,
            RedirectStandardError = false
        };

        using Process? process = Process.Start(psi);
        if (process != null)
        {
            process.WaitForExit();
            
            if (process.ExitCode == 0)
            {
                AppendStatus("Installation completed successfully!\r\n");
                MessageBox.Show("Installation completed successfully!", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            else
            {
                AppendStatus($"Installation exited with code: {process.ExitCode}\r\n");
                AppendStatus("Note: Some MSI files may require admin privileges or have specific installation requirements.\r\n");
            }
        }
    }

    private void ExtractMsi(string msiPath, string extractPath)
    {
        AppendStatus($"Extracting: {msiPath}\r\n");
        AppendStatus($"To: {extractPath}\r\n");

        // Create extraction directory
        Directory.CreateDirectory(extractPath);

        // Use msiexec to extract (admin command)
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
            string output = process.StandardOutput.ReadToEnd();
            string error = process.StandardError.ReadToEnd();
            
            process.WaitForExit();

            if (!string.IsNullOrWhiteSpace(output))
            {
                AppendStatus($"Output: {output}\r\n");
            }

            if (!string.IsNullOrWhiteSpace(error))
            {
                AppendStatus($"Error: {error}\r\n");
            }

            if (process.ExitCode == 0)
            {
                AppendStatus("Extraction completed successfully!\r\n");
                
                // Generate readme file
                GenerateReadmeHtml(extractPath);
                
                AppendStatus($"readmeINSTALL.html generated in: {extractPath}\r\n");
                MessageBox.Show($"Extraction completed successfully!\n\nFiles extracted to:\n{extractPath}\n\nA readmeINSTALL.html file has been created with installation details.", 
                    "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            else
            {
                AppendStatus($"Extraction exited with code: {process.ExitCode}\r\n");
            }
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
        File.WriteAllText(readmePath, html.ToString());
    }

    private void GenerateFileTree(string rootPath, string currentPath, StringBuilder html, int level)
    {
        try
        {
            string indent = new string(' ', level * 4);
            
            // Get directories
            var directories = Directory.GetDirectories(currentPath);
            foreach (var dir in directories)
            {
                string dirName = Path.GetFileName(dir);
                string relativePath = Path.GetRelativePath(rootPath, dir);
                html.AppendLine($"        <div class='folder' style='margin-left: {level * 20}px;'>📁 {dirName}/</div>");
                GenerateFileTree(rootPath, dir, html, level + 1);
            }

            // Get files
            var files = Directory.GetFiles(currentPath);
            foreach (var file in files)
            {
                string fileName = Path.GetFileName(file);
                if (fileName == "readmeINSTALL.html") continue; // Skip the readme itself
                
                string relativePath = Path.GetRelativePath(rootPath, file);
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

    private void AppendStatus(string message)
    {
        if (txtStatus.InvokeRequired)
        {
            txtStatus.Invoke(() => AppendStatus(message));
        }
        else
        {
            txtStatus.AppendText(message);
        }
    }
}
