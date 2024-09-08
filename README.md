# 🎨 PowerShell Profile

Linux terminal experience on windows.

## 🛠️  (Elevated PowerShell Recommended)

Execute the following command in an elevated PowerShell window to install the PowerShell profile:

```powershell
irm "https://github.com/its-ashu-otf/powershell-profile/raw/main/setup.ps1" | iex
```


## 🛠️ Fix the Missing Font

After running the script, you'll have two options for installing a font patched to support icons in PowerShell:

### 1) You will find a downloaded `cove.zip` file in the folder you executed the script from. Follow these steps to install the patched `Caskadia Mono` nerd font family:

1. Extract the `cove.zip` file.
2. Locate and install the nerd fonts.

### 2) With `oh-my-posh` (loaded automatically through the PowerShell profile script hosted on this repo):
1. Run the command `oh-my-posh font install`
2. A list of Nerd Fonts will appear like so:
<pre>
PS> oh-my-posh font install

   Select font

  > 0xProto
    3270
    Agave
    AnonymousPro
    Arimo
    AurulentSansMono
    BigBlueTerminal
    BitstreamVeraSansMono

    •••••••••
    ↑/k up • ↓/j down • q quit • ? more</pre>
3. With the up/down arrow keys, select the font you would like to install and press <kbd>ENTER</kbd>
4. DONE!

## Customize this profile

**Do not make any changes to the `Microsoft.PowerShell_profile.ps1` file**, since it's hashed and automatically overwritten by any commits to this repository.
Now, enjoy your enhanced and stylish PowerShell experience! 🚀
