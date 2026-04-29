<#
.SYNOPSIS
    GUI tool for converting files to/from Base64.

.FEATURES
    - Drag & drop a file onto the window to convert it to Base64 (copied to clipboard)
    - "From: Base64" button reads Base64 from clipboard, detects file type by magic bytes,
      and saves the decoded file to your Downloads folder
    - Supports: PNG, JPG, GIF, PDF, ZIP, EXE
    - Hides the PowerShell console window on launch

.USAGE
    To Base64 encode : Drag and drop any file onto the drop zone
    To Base64 decode : Copy a Base64 string to clipboard, then click "From: Base64"
#>
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Get-FileTypeFromBytes {
    param ([byte[]]$Bytes)
    $sig = [BitConverter]::ToString($Bytes, 0, [Math]::Min(4, $Bytes.Length)).Replace('-', '')
    switch ($sig) {
        '89504E47'              { 'png' }
        { $_ -like 'FFD8FFE?' } { 'jpg' }
        '47494638'              { 'gif' }
        '25504446'              { 'pdf' }
        '504B0304'              { 'zip' }
        { $_ -like '4D5A*' }   { 'exe' }
        default                 { 'unknown' }
    }
}

function Save-FileFromBase64 {
    param (
        [string]$Base64String,
        [string]$OutputDirectory
    )
    # Decode only the first 8 Base64 chars (6 bytes) to detect file type before full decode
    $headerBytes = [Convert]::FromBase64String($Base64String.Substring(0, [Math]::Min(8, $Base64String.Length)))
    $FileType = Get-FileTypeFromBytes -Bytes $headerBytes
    if ($FileType -eq 'unknown') {
        Write-Output "Unknown file type. Cannot save the file."
        return
    }
    $FileBytes = [Convert]::FromBase64String($Base64String)
    $FileName = [System.IO.Path]::Combine($OutputDirectory, [System.Guid]::NewGuid().ToString() + ".$FileType")
    [System.IO.File]::WriteAllBytes($FileName, $FileBytes)
}

function ConvertTo-Base64 {
    param ([string]$FilePath)
    $Base64_Code = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($FilePath))
    Set-Clipboard -Value $Base64_Code
    [System.Windows.Forms.MessageBox]::Show("Base64 sent to clipboard.", "Base64 --> Clipboard", 'OK', 'Information')
}

function Show-Error {
    [System.Windows.Forms.MessageBox]::Show($Error[0].Exception.Message, 'ERROR', 'OK', 'ERROR')
}

$IconBase64 = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAEG0lEQVRoQ9WZTWgTQRTH5yVpI21B8AOttKBSQRRqYgTRg+i19GqhNC14KnjWU0EEsQfBowe92UTBeBTrTQ8eRAptEKQHLQpGK0Kh4EfZtpvx7SYbdzfzPVutc0qyM+/9fzNv3rydANmiRks5CuNVCJtn/WbrPuLA1lgw3hPqfQ4D0LuFLtLl/oz/buszcYBAfBvAzGA3gdSPpuBfCNdtK973kYSRSJjMDmRh6L1DKQEA4q9EvCHkTQSYSsJ34gBJiNKxkRgALRcuE+reSTrGZTCJAITjPnAYz0CtDV7OfcfA6vG/L1XTcJ3UZSJFz60BWOJ5ELSc+4ri98UF8WBVwKwAROJZoaQDqyLeOgslCYA5ax6KCwVV4a1V1h3QiuVS7ht+3iuMz9BJTB8WjhLXXVTtr6rLOIRksx8PIVrOfyGU9oqFpaZhfF7rfFAGoDP5UwToXLDhtAGa5YVsZnU3tDpArL7BjFLHjCIcH6mF/iUAq77B4qwDi7N11ZhGG7ew79V/sgK8MlgYRlgHQbGaCguWhh1jjBRY1kH03CvYiBdKjMaKZRmAyfuD0h6g5dN9hDqffJ3ZIxkYeey20mmlsJM47mqEIbuRhZG3beGF++YJ7pth3qSwAFgHYni8FIAzazV01m+yerxV4Im3AsAZc3DGOplCUx15GJurGkJ4q9nnjwV4iSfwOZYd+qhwgay7z0WpVbgCujFrAmM7hgtAKxfTxHm3KXOge/AIk0LbWQGLML5wTJiqeQ9pKb9MCN0vA8Dn9xBiUqEftwstD2KSSDWSRHtbR/tZ7sbnA+Q28FlGRZjtKtiEKj+EyrkPuIEPqgBgn2WEOKDYN9JNJr6x0ckrPBTPsuxbbeKwQZNVQPEO2mBnuZhanv1EAEzEe/qUZr8JsoUAsISZYkA3fDBJnEAE1XNkDQG6tENIYZbqaDgdNkwrZ3YRZ20l5qytn4LtPyZ29+6AoWdeuLU1aSkhcqRbsLWVCy/OZ0ht1ct2wmZ8EkdmNnbI6Ir3bdF6D0y88S94g0Yf5CdInd4XESQCIJsl1ZDggHslOTMaZAlCKYQUxc9jv7ysL/fGjvXKCXAbC70rwtWROVR9rpwSY+8Tcfu0dHKSZNKzMDrHKy0iQxJZAWXxTdeysFCdNK+fNYCu+IY4WMGzY4+OUF5fKwAz8YGU1BReYk3bQhgBoHDvesS7JrFrGTIMo9WnNka0AexmnSEVsv1QfF0zhdACQPEldFQ0dcaN49jfsTr2dQGYf9rpOEwaYtsAkE1yCC5VP+pOxvYBSMENGFu49t8CmB5ueitQOd5JnA5mXa47c/H+fwXAc6ryv4ABzGcEaNzUaTatFQhsYzrllr+a/v3uprPvjzVxGAKJplUgNbz+YF764sot4TXN4bA/G+GBnd/2jblAobJvMgAAAABJRU5ErkJggg=="
$IconBytes = [Convert]::FromBase64String($IconBase64)
$ims = [System.IO.MemoryStream]::new($IconBytes, 0, $IconBytes.Length)

# Tokyo Night theme colors
$tnBg       = [System.Drawing.Color]::FromArgb(26,  27,  38)   # #1a1b26
$tnSurface  = [System.Drawing.Color]::FromArgb(41,  46,  66)   # #292e42
$tnFg       = [System.Drawing.Color]::FromArgb(192, 202, 245)  # #c0caf5
$tnBlue     = [System.Drawing.Color]::FromArgb(122, 162, 247)  # #7aa2f7
$tnBorder   = [System.Drawing.Color]::FromArgb(65,  72,  104)  # #414868

$form = New-Object System.Windows.Forms.Form
$form.Text = "Base64 Converter"
$form.Size = New-Object System.Drawing.Size(300, 165)
$form.Icon = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $ims).GetHIcon())
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.BackColor = $tnBg
$form.ShowInTaskbar = $false
$form.ForeColor = $tnFg

$dropPanel = New-Object System.Windows.Forms.Panel
$dropPanel.Location = New-Object System.Drawing.Point(10, 10)
$dropPanel.Size = New-Object System.Drawing.Size(267, 52)
$dropPanel.BackColor = $tnSurface
$dropPanel.AllowDrop = $true
$dropPanel.BorderStyle = 'FixedSingle'
$dropPanelText = New-Object System.Windows.Forms.Label
$dropPanelText.Text = "Drag and Drop File Here"
$dropPanelText.AutoSize = $true
$dropPanelText.ForeColor = $tnFg
$dropPanelText.Location = New-Object System.Drawing.Point(68, 17)
$dropPanel.Controls.Add($dropPanelText)
$form.Controls.Add($dropPanel)

$dropPanel.Add_DragEnter({
    param ($s, $e)
    if ($e.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
        $e.Effect = [System.Windows.Forms.DragDropEffects]::Copy
    }
})

$dropPanel.Add_DragDrop({
    param ($s, $e)
    $droppedFiles = $e.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
    if ($droppedFiles.Length -gt 0) {
        try {
            ConvertTo-Base64 -FilePath $droppedFiles[0]
        } catch {
            Show-Error
        }
    }
})

$frombase64Button = New-Object System.Windows.Forms.Button
$frombase64Button.Text = "From: Base64"
$frombase64Button.Location = New-Object System.Drawing.Point(95, 75)
$frombase64Button.Size = New-Object System.Drawing.Size(110, 32)
$frombase64Button.FlatStyle = 'Flat'
$frombase64Button.BackColor = $tnBlue
$frombase64Button.ForeColor = $tnBg
$frombase64Button.FlatAppearance.BorderColor = $tnBlue
$frombase64Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(149, 180, 248)
$frombase64Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(99, 135, 220)
$frombase64Button.UseVisualStyleBackColor = $false
$form.Controls.Add($frombase64Button)

$frombase64Button.Add_Click({
    try {
        $base64String = Get-Clipboard
        $outputDirectory = [Environment]::GetFolderPath('UserProfile') + '\Downloads'
        Save-FileFromBase64 -Base64String $base64String -OutputDirectory $outputDirectory
        [System.Windows.Forms.MessageBox]::Show("Your file has been saved here:`n`n$outputDirectory", "Clipboard --> Base64", 'OK', 'Information')
    } catch {
        Show-Error
    }
})

$Help_Image = New-Object System.Windows.Forms.Label
$HelpIconBase64 = 'iVBORw0KGgoAAAANSUhEUgAAABkAAAAZCAYAAADE6YVjAAAAxklEQVRIS8WW0Q2AIAxEZTz/HcKRHMJ/x9NAgkGE3h0Y9JfS1zsK1U3ENy/rWQs79s2hFGaAlTxPbMGKECU5A3tBegARmKt6QL4AlEA3BAFKnrN7KIh1qEznBQgTaLUp2i9B0mSpOghBvjKXEOVwKGA4pNYAqFBJSUsbeye6IEhBtLoZwgJkJX6Dt0wBBAi6jGhWoHVflAxRldwQVg17y/OXmHogS883cy6xqLHzJFbLVMgcdhrzz4xPK1BUyX8ruR1oXiD7LvmhkjZLp5jjAAAAAElFTkSuQmCC'
$HelpIconBytes = [Convert]::FromBase64String($HelpIconBase64)
$Stream = [System.IO.MemoryStream]::new($HelpIconBytes, 0, $HelpIconBytes.Length)
$Custom_Bookmark_Help_Picture = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($Stream).GetHIcon()))
$ResizedImage = $Custom_Bookmark_Help_Picture.ToBitmap().GetThumbnailImage(20, 20, $null, [System.IntPtr]::Zero)
$Help_Image.Image = $ResizedImage
$Help_Image.Size = New-Object System.Drawing.Size(20, 20)
$Help_Image.Location = New-Object System.Drawing.Point(65, 83)
$Help_Image.BringToFront()
$form.Controls.Add($Help_Image)

$Help_Image.Add_Click({
    [System.Windows.Forms.MessageBox]::Show("Copy the Base64 code into your clipboard then click the `"From: Base64`" button.`nThe file will then be saved into your downloads folder.", "Help", 'OK', 'Information')
})

# Make PowerShell Disappear
$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
$asyncwindow = Add-Type -MemberDefinition $windowcode -Name Win32ShowWindowAsync -Namespace Win32Functions -PassThru
$null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)


$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
