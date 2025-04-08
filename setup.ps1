# Ensure the script can run with elevated privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as an Administrator!"
    exit
}

# Display banner
$banner = @"
    __  ______  _                 __          ____                          _____ __         ____
   / / / / / /_(_)___ ___  ____ _/ /____     / __ \____ _      _____  _____/ ___// /_  ___  / / /
  / / / / / __/ / __ `__ \/ __ `/ __/ _ \   / /_/ / __ \ | /| / / _ \/ ___/\__ \/ __ \/ _ \/ / / 
 / /_/ / / /_/ / / / / / / /_/ / /_/  __/  / ____/ /_/ / |/ |/ /  __/ /   ___/ / / / /  __/ / /  
 \____/_/\__/_/_/ /_/ /_/\__,_/\__/\___/  /_/    \____/|__/|__/\___/_/   /____/_/ /_/\___/_/_/   
                                                                                                
"@
Write-Host $banner -ForegroundColor Blue
Write-Host "Author: its-ashu-otf" -ForegroundColor Cyan
Write-Host "Welcome to the Ultimate PowerShell Setup Script!" -ForegroundColor Green
Write-Host ""

# Function to test internet connectivity
function Test-InternetConnection {
    try {
        Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        Write-Warning "Internet connection is required but not available. Please check your connection."
        return $false
    }
}

# Check for internet connectivity before proceeding
if (-not (Test-InternetConnection)) {
    exit
}

# Ensure winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget is not installed or not available in the PATH. Please install winget and try again."
    exit
}

# Profile creation or update
function Update-Profile {
    try {
        $profilePath = if ($PSVersionTable.PSEdition -eq "Core") {
            "$env:USERPROFILE\Documents\Powershell"
        } else {
            "$env:USERPROFILE\Documents\WindowsPowerShell"
        }

        if (!(Test-Path -Path $profilePath)) {
            New-Item -Path $profilePath -ItemType "directory" -Force | Out-Null
        }

        if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
            Invoke-RestMethod -Uri "https://github.com/its-ashu-otf/powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1" -OutFile $PROFILE
            Write-Host "The profile @ [$PROFILE] has been created."
        } else {
            Move-Item -Path $PROFILE -Destination "$PROFILE.old" -Force
            Invoke-RestMethod -Uri "https://github.com/its-ashu-otf/powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1" -OutFile $PROFILE
            Write-Host "The profile @ [$PROFILE] has been updated and the old profile has been backed up."
        }
    }
    catch {
        Write-Error "Failed to create or update the profile. Error: $_"
    }
}

Update-Profile

# Install Oh My Posh
try {
    winget install -e --accept-source-agreements --accept-package-agreements JanDeDobbeleer.OhMyPosh 
    Write-Host "Oh My Posh installed successfully."
}
catch {
    Write-Error "Failed to install Oh My Posh. Error: $_"
}

# Function to install Nerd Fonts
function Install-NerdFonts {
    param (
        [string]$FontName = "CascadiaCode",
        [string]$FontDisplayName = "CaskaydiaCove NF"
    )

    try {
        Add-Type -AssemblyName System.Drawing
        $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families | ForEach-Object { $_.Name }
        if ($fontFamilies -notcontains $FontDisplayName) {
            $fontZipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FontName}.zip"
            $zipFilePath = "$env:TEMP\${FontName}.zip"
            $extractPath = "$env:TEMP\${FontName}"

            Invoke-WebRequest -Uri $fontZipUrl -OutFile $zipFilePath
            Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force

            $destination = (New-Object -ComObject Shell.Application).Namespace("C:\Windows\Fonts")
            Get-ChildItem -Path $extractPath -Recurse -Filter "*.ttf" | ForEach-Object {
                If (-not (Test-Path "C:\Windows\Fonts\$($_.Name)")) {
                    $destination.CopyHere($_.FullName, 0x10)
                }
            }

            Remove-Item -Path $extractPath -Recurse -Force
            Remove-Item -Path $zipFilePath -Force
            Write-Host "Font $FontDisplayName installed successfully."
        } else {
            Write-Host "Font $FontDisplayName is already installed."
        }
    }
    catch {
        Write-Error "Failed to download or install $FontDisplayName font. Error: $_"
    }
}

# Install CascadiaMono Nerd Font
Install-NerdFonts -FontName "CascadiaMono" -FontDisplayName "CaskaydiaMono NF"

# Final check and message to the user
try {
    Add-Type -AssemblyName System.Drawing
    $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families | ForEach-Object { $_.Name }
    if ((Test-Path -Path $PROFILE) -and (winget list --name "OhMyPosh" -e) -and ($fontFamilies -contains "CaskaydiaMono NF")) {
        Write-Host "Setup completed successfully. Please restart your PowerShell session to apply changes."
    } else {
        Write-Warning "Setup completed with errors. Please check the error messages above."
    }
}
catch {
    Write-Error "Failed during final check. Error: $_"
}

# Install Terminal Icons
try {
    Install-Module -Name Terminal-Icons -Repository PSGallery -Force
    Write-Host "Terminal Icons module installed successfully."
}
catch {
    Write-Error "Failed to install Terminal Icons module. Error: $_"
}

# Install PSCompletions
try {
    Install-Module -Name PSCompletions -Scope CurrentUser -Repository PSGallery -Force
    Write-Host "PSCompletions module installed successfully."
}
catch {
    Write-Error "Failed to install PSCompletions module. Error: $_"
}

# Install Linux Tools
function Install-LinuxTools {
    $tools = @(
        "Fastfetch-cli.Fastfetch",
        "ajeetdsouza.zoxide",
        "junegunn.fzf",
        "cURL.cURL",
        "sharkdp.bat",
        "Git.Git",
        "GNU.Wget2"
    )

    foreach ($tool in $tools) {
        try {
            winget install -e --id $tool --accept-source-agreements --accept-package-agreements -Force
            Write-Host "$tool installed successfully."
        }
        catch {
            Write-Error "Failed to install $tool. Error: $_"
        }
    }
}

Install-LinuxTools
