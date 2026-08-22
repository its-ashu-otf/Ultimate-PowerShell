# 🧑🏻‍💻 Ultimate-PowerShell

Linux terminal experience on windows with a quality of life aliases and shortcuts.

## ⚡ One Liner to Install  (Elevated PowerShell Recommended)

Execute the following command in an elevated PowerShell window to install the PowerShell profile:

```powershell
irm "https://github.com/its-ashu-otf/Ultimate-PowerShell/raw/main/setup.ps1" | iex
```


## 🛠️ Change the Font

### 1) With `oh-my-posh` (loaded automatically through the PowerShell profile script hosted on this repo):
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

After the profile is installed and active, run the `Edit-Profile` function to create a separate profile file for your current user. Make any changes and customizations in this new file named `profile.ps1`.

Now, enjoy your enhanced and stylish PowerShell experience! 🚀
