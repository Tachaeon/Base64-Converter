# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running the Tool

```powershell
PowerShell.exe -ExecutionPolicy Bypass -File .\Get-Base64.ps1
```

## Architecture

This is a single-file PowerShell GUI application (`Get-Base64.ps1`) using Windows Forms. There is no build step, no dependencies, and no tests — the script runs directly.

**Key components within `Get-Base64.ps1`:**

- `Get-FileTypeFromBase64` — detects file type from magic bytes in the decoded data (PNG, JPG, GIF, PDF, ZIP, EXE)
- `Save-FileFromBase64` — decodes Base64 from clipboard and writes the file to the user's Downloads folder with a GUID-based filename
- `ConvertTo-Base64` — reads a file's raw bytes, Base64-encodes them, and writes to clipboard
- The GUI form uses a drag-and-drop panel (encodes on drop) and a "From: Base64" button (decodes from clipboard)
- The app icon and help icon are embedded as inline Base64 strings
- The PowerShell console window is hidden at startup via `user32.dll ShowWindowAsync`
