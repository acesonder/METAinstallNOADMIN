namespace MSIInstaller;

partial class Form1
{
    /// <summary>
    ///  Required designer variable.
    /// </summary>
    private System.ComponentModel.IContainer components = null;

    /// <summary>
    ///  Clean up any resources being used.
    /// </summary>
    /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    protected override void Dispose(bool disposing)
    {
        if (disposing && (components != null))
        {
            components.Dispose();
        }
        base.Dispose(disposing);
    }

    #region Windows Form Designer generated code

    /// <summary>
    ///  Required method for Designer support - do not modify
    ///  the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
        lblMsiPath = new Label();
        txtMsiPath = new TextBox();
        btnBrowseMsi = new Button();
        btnInstall = new Button();
        btnExtract = new Button();
        lblStatus = new Label();
        txtStatus = new TextBox();
        lblExtractPath = new Label();
        txtExtractPath = new TextBox();
        btnBrowseExtract = new Button();
        SuspendLayout();
        // 
        // lblMsiPath
        // 
        lblMsiPath.AutoSize = true;
        lblMsiPath.Location = new Point(20, 20);
        lblMsiPath.Name = "lblMsiPath";
        lblMsiPath.Size = new Size(97, 15);
        lblMsiPath.TabIndex = 0;
        lblMsiPath.Text = "MSI Installer File:";
        // 
        // txtMsiPath
        // 
        txtMsiPath.Location = new Point(20, 40);
        txtMsiPath.Name = "txtMsiPath";
        txtMsiPath.Size = new Size(550, 23);
        txtMsiPath.TabIndex = 1;
        // 
        // btnBrowseMsi
        // 
        btnBrowseMsi.Location = new Point(580, 39);
        btnBrowseMsi.Name = "btnBrowseMsi";
        btnBrowseMsi.Size = new Size(100, 25);
        btnBrowseMsi.TabIndex = 2;
        btnBrowseMsi.Text = "Browse...";
        btnBrowseMsi.UseVisualStyleBackColor = true;
        btnBrowseMsi.Click += BtnBrowseMsi_Click;
        // 
        // lblExtractPath
        // 
        lblExtractPath.AutoSize = true;
        lblExtractPath.Location = new Point(20, 80);
        lblExtractPath.Name = "lblExtractPath";
        lblExtractPath.Size = new Size(106, 15);
        lblExtractPath.TabIndex = 3;
        lblExtractPath.Text = "Extract to Folder:";
        // 
        // txtExtractPath
        // 
        txtExtractPath.Location = new Point(20, 100);
        txtExtractPath.Name = "txtExtractPath";
        txtExtractPath.Size = new Size(550, 23);
        txtExtractPath.TabIndex = 4;
        // 
        // btnBrowseExtract
        // 
        btnBrowseExtract.Location = new Point(580, 99);
        btnBrowseExtract.Name = "btnBrowseExtract";
        btnBrowseExtract.Size = new Size(100, 25);
        btnBrowseExtract.TabIndex = 5;
        btnBrowseExtract.Text = "Browse...";
        btnBrowseExtract.UseVisualStyleBackColor = true;
        btnBrowseExtract.Click += BtnBrowseExtract_Click;
        // 
        // btnInstall
        // 
        btnInstall.Location = new Point(20, 140);
        btnInstall.Name = "btnInstall";
        btnInstall.Size = new Size(200, 40);
        btnInstall.TabIndex = 6;
        btnInstall.Text = "Install MSI (No Admin)";
        btnInstall.UseVisualStyleBackColor = true;
        btnInstall.Click += BtnInstall_Click;
        // 
        // btnExtract
        // 
        btnExtract.Location = new Point(240, 140);
        btnExtract.Name = "btnExtract";
        btnExtract.Size = new Size(200, 40);
        btnExtract.TabIndex = 7;
        btnExtract.Text = "Extract MSI Contents";
        btnExtract.UseVisualStyleBackColor = true;
        btnExtract.Click += BtnExtract_Click;
        // 
        // lblStatus
        // 
        lblStatus.AutoSize = true;
        lblStatus.Location = new Point(20, 200);
        lblStatus.Name = "lblStatus";
        lblStatus.Size = new Size(42, 15);
        lblStatus.TabIndex = 8;
        lblStatus.Text = "Status:";
        // 
        // txtStatus
        // 
        txtStatus.Location = new Point(20, 220);
        txtStatus.Multiline = true;
        txtStatus.Name = "txtStatus";
        txtStatus.ReadOnly = true;
        txtStatus.ScrollBars = ScrollBars.Vertical;
        txtStatus.Size = new Size(660, 200);
        txtStatus.TabIndex = 9;
        // 
        // Form1
        // 
        AutoScaleDimensions = new SizeF(7F, 15F);
        AutoScaleMode = AutoScaleMode.Font;
        ClientSize = new Size(700, 450);
        Controls.Add(txtStatus);
        Controls.Add(lblStatus);
        Controls.Add(btnExtract);
        Controls.Add(btnInstall);
        Controls.Add(btnBrowseExtract);
        Controls.Add(txtExtractPath);
        Controls.Add(lblExtractPath);
        Controls.Add(btnBrowseMsi);
        Controls.Add(txtMsiPath);
        Controls.Add(lblMsiPath);
        Name = "Form1";
        Text = "MSI Installer - No Admin Required";
        ResumeLayout(false);
        PerformLayout();
    }

    #endregion

    private Label lblMsiPath;
    private TextBox txtMsiPath;
    private Button btnBrowseMsi;
    private Button btnInstall;
    private Button btnExtract;
    private Label lblStatus;
    private TextBox txtStatus;
    private Label lblExtractPath;
    private TextBox txtExtractPath;
    private Button btnBrowseExtract;
}
