# Function to check if running with elevated privileges (admin/root)
function Test-Admin {
    if ($IsWindows) {
        return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    elseif ($IsMacOS -or $IsLinux) {
        return $(whoami) -eq "root"
    }
    else {
        return $false
    }
}

# Function to test internet connectivity
function Test-InternetConnection {
    try {
        $testConnection = Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop
        return $true
    }
    catch {
        Write-Warning "Internet connection is required but not available. Please check your connection."
        return $false
    }
}

# Check if running with elevated privileges
$isadmin = Test-Admin

# Check for internet connectivity before proceeding
if (-not (Test-InternetConnection)) {
    Write-Warning "Setup requires internet connectivity. Please connect to the internet and rerun the script."
    exit 1
}

# Profile creation or update
$profilePath = ""
if ($PSVersionTable.PSEdition -eq "Core") { 
    $profilePath = "$env:userprofile\Documents\PowerShell"
}
elseif ($PSVersionTable.PSEdition -eq "Desktop") {
    $profilePath = "$env:userprofile\Documents\WindowsPowerShell"
}

if (!(Test-Path -Path $profilePath)) {
    try {
        New-Item -Path $profilePath -ItemType Directory | Out-Null
    }
    catch {
        Write-Error "Failed to create profile directory: $_"
        exit 1
    }
}

try {
    if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
        Invoke-RestMethod -Uri "https://github.com/its-ashu-otf/powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1" -OutFile $PROFILE
        Write-Host "Profile created: $PROFILE"
        Write-Host "Customize persistent components in: $profilePath\Profile.ps1 to avoid overwrite."
    }
    else {
        Move-Item -Path $PROFILE -Destination "oldprofile.ps1" -Force
        Invoke-RestMethod -Uri "https://github.com/ChrisTitusTech/powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1" -OutFile $PROFILE
        Write-Host "Profile updated and old profile backed up."
        Write-Host "Customize persistent components in: $profilePath\Profile.ps1 to avoid overwrite."
    }
}
catch {
    Write-Error "Failed to create or update the profile. Error: $_"
    exit 1
}

# Install Oh My Posh (OMP)
try {
    winget install -e --accept-source-agreements --accept-package-agreements JanDeDobbeleer.OhMyPosh
}
catch {
    Write-Error "Failed to install Oh My Posh. Error: $_"
    exit 1
}

# Install Cascadia Code font if not installed
try {
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name

    if ($fontFamilies -notcontains "CaskaydiaCove NF") {
        $fontDownloadUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/CascadiaCode.zip"
        $fontDestination = "$env:TEMP\CascadiaCode.zip"
        $fontExtractPath = "$env:TEMP\CascadiaCode"

        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($fontDownloadUrl, $fontDestination)

        Expand-Archive -Path $fontDestination -DestinationPath $fontExtractPath -Force
        Copy-Item -Path "$fontExtractPath\*.ttf" -Destination "C:\Windows\Fonts\" -Force

        Remove-Item -Path $fontDestination -Force
        Remove-Item -Path $fontExtractPath -Recurse -Force
    }
}
catch {
    Write-Error "Failed to download or install the Cascadia Code font. Error: $_"
    exit 1
}

# Final check and message to the user
if ((Test-Path -Path $PROFILE -PathType Leaf) -and (winget list --name "OhMyPosh" -e) -and ($fontFamilies -contains "CaskaydiaCove NF")) {
    Write-Host "Setup completed successfully. Please restart your PowerShell session to apply changes."
} else {
    Write-Warning "Setup completed with errors. Please check the error messages above."
    exit 1
}

# Install Chocolatey (Choco)
try {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
catch {
    Write-Error "Failed to install Chocolatey. Error: $_"
    exit 1
}

# Install Terminal Icons module
try {
    Install-Module -Name Terminal-Icons -Repository PSGallery -Force
}
catch {
    Write-Error "Failed to install Terminal Icons module. Error: $_"
    exit 1
}

# Additional installs
try {
    winget install fastfetch
    winget install -e --id Microsoft.PowerShell
    winget install -e --id ajeetdsouza.zoxide
    Write-Host "Dependencies installed successfully."
}
catch {
    Write-Error "Failed to install dependencies. Error: $_"
    exit 1
}
