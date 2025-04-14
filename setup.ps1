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
        Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop
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

# Profile creation or update
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    try {
        # Detect Version of PowerShell & Create Profile directories if they do not exist
        $profilePath = ""
        if ($PSVersionTable.PSEdition -eq "Core") { 
            $profilePath = "$env:USERPROFILE\Documents\Powershell"
        }
        elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            $profilePath = "$env:USERPROFILE\Documents\WindowsPowerShell"
        }

        if (!(Test-Path -Path $profilePath)) {
            New-Item -Path $profilePath -ItemType "directory"
        }

        Invoke-RestMethod -Uri "https://github.com/its-ashu-otf/powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1" -OutFile $PROFILE
        Write-Host "The profile @ [$PROFILE] has been created."
        Write-Host "If you want to make any personal changes or customizations, please do so at [$profilePath\Profile.ps1] as there is an updater in the installed profile which uses the hash to update the profile and will lead to loss of changes."
    }
    catch {
        Write-Error "Failed to create or update the profile. Error: $_"
    }
}
else {
    try {
        Move-Item -Path $PROFILE -Destination "$PROFILE.old" -Force
        Invoke-RestMethod -Uri "https://github.com/its-ashu-otf/powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1" -OutFile $PROFILE
        Write-Host "The profile @ [$PROFILE] has been updated and the old profile has been backed up."
        Write-Host "Please back up any persistent components of your old profile to [$HOME\Documents\PowerShell\Profile.ps1] as there is an updater in the installed profile which uses the hash to update the profile and will lead to loss of changes."
    }
    catch {
        Write-Error "Failed to backup and update the profile. Error: $_"
    }
}

# OMP Install
try {
    winget install -e --accept-source-agreements --accept-package-agreements JanDeDobbeleer.OhMyPosh
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

            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($fontZipUrl, $zipFilePath)

            Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force
            $destination = (New-Object -ComObject Shell.Application).Namespace("C:\Windows\Fonts")
            Get-ChildItem -Path $extractPath -Recurse -Filter "*.ttf" | ForEach-Object {
                If (-not (Test-Path "C:\Windows\Fonts\$($_.Name)")) {
                    $destination.CopyHere($_.FullName, 0x10)
                }
            }

            Remove-Item -Path $extractPath -Recurse -Force
            Remove-Item -Path $zipFilePath -Force
        }
        else {
            Write-Host "Font $FontDisplayName is already installed."
        }
    }
    catch {
        Write-Error "Failed to download or install $FontDisplayName font. Error: $_"
    }
}

# Font Install
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

# Terminal Icons Install
try {
    Install-Module -Name Terminal-Icons -Repository PSGallery -Force
}
catch {
    Write-Error "Failed to install Terminal Icons module. Error: $_"
}

# PSCompletions Install
try {
    Install-Module -Name PSCompletions -Scope CurrentUser -Repository PSGallery -Force
}
catch {
    Write-Error "Failed to install PSCompletions module. Error: $_"
}

# Linux Tools Install
try {
    winget install -e --id Fastfetch-cli.Fastfetch
    winget install -e --id ajeetdsouza.zoxide
    winget install -e --id junegunn.fzf
    winget install -e --id cURL.cURL
    winget install -e --id sharkdp.bat 
    winget install -e --id Git.Git
    winget install -e --id GNU.Wget2    
    Write-Host "Linux tools installed successfully."
}
catch {
    Write-Error "Failed to install Linux tools. Error: $_"
}
