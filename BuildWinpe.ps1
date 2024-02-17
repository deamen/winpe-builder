$ErrorActionPreference = "Stop"
# Define paths
$winpe_root = Join-Path -Path $PSScriptRoot -ChildPath "winpe-workdir"
$adk_path = Join-Path -Path "$env:ProgramFiles (x86)" -ChildPath "Windows Kits\10\Assessment and Deployment Kit"
$drivers_path = Join-Path -Path $PSScriptRoot -ChildPath "drivers"
$scripts_path = Join-Path -Path $PSScriptRoot -ChildPath "scripts"
$packages_path = Join-Path -Path $PSScriptRoot -ChildPath "packages"
$addons_path = Join-Path -Path $PSScriptRoot -ChildPath "addons"
$artefacts_path = Join-Path -Path $PSScriptRoot -ChildPath "out"

# Importing DandISetEnv.bat environment variables (Manual conversion required if environment settings are critical)

# Cleanup WinPE tree
if (Test-Path $winpe_root) {
    Remove-Item -Path $winpe_root -Recurse -Force
}

Write-Host "Copying WinPE tree"
# Chain run of DandISetEnv.bat and copype.cmd, so the variables are set for the copype.cmd command
$cmdCommands = "call `"$adk_path\Deployment Tools\DandISetEnv.bat`" & copype.cmd amd64 $winpe_root"
Start-Process "cmd.exe" -ArgumentList "/c $cmdCommands" -NoNewWindow -Wait
Write-Host "Finished Copying WinPE tree"

Write-Host "Mounting WinPE wim-image"
Dism /Mount-Wim /WimFile:"$winpe_root\media\sources\boot.wim" /index:1 /MountDir:"$winpe_root\mount"

Write-Host "Adding packages to WinPE"
$packages = @(
    "WinPE-HTA",
    "WinPE-WMI",
    "WinPE-StorageWMI",
    "WinPE-Scripting",
    "WinPE-NetFx",
    "WinPE-PowerShell",
    "WinPE-DismCmdlets",
    "WinPE-FMAPI",
    "WinPE-SecureBootCmdlets",
    "WinPE-EnhancedStorage",
    "WinPE-SecureStartup"
)

foreach ($package in $packages) {
    $packagePath = Join-Path -Path "$adk_path\Windows Preinstallation Environment\amd64\WinPE_OCs" -ChildPath "$package.cab"
    Dism /image:"$winpe_root\mount" /Add-Package /PackagePath:$packagePath
    $langPackagePath = Join-Path -Path "$adk_path\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us" -ChildPath "$($package)_en-us.cab"
    if (Test-Path $langPackagePath) {
        Dism /image:"$winpe_root\mount" /Add-Package /PackagePath:$langPackagePath
    }
}

Write-Host "Adding drivers to WinPE"
Dism /image:"$winpe_root\mount" /Add-Driver /driver:$drivers_path /recurse

Write-Host "Adding Windows Update to WinPE"
Dism /image:"$winpe_root\mount" /Add-Package /PackagePath:"$packages_path"

Write-Host "Locking in the update"
mkdir ${winpe_root}\temp
Dism /image:"$winpe_root\mount" /Cleanup-Image /StartComponentCleanup /ResetBase /ScratchDir:${winpe_root}\temp

Write-Host "Copying scripts to the WinPE system32 directory"
Copy-Item -Path $scripts_path\*.cmd -Destination "$winpe_root\mount\Windows\System32" -Recurse -Force

Write-Host "Copying Add-ons to the WinPE root directory"
Copy-Item -Path $addons_path\* -Destination "$winpe_root\mount\" -Recurse -Force

# There is no en-au avaialble in the WinPE_OCs folder, so we need to set the language to en-us

# Set region and language
Dism /Set-AllIntl:en-us /Image:"$winpe_root\mount"

# Set timezone
Dism /image:"$winpe_root\mount" /Set-TimeZone:"Eastern Standard Time"

# Unmount and commit changes
Dism /Unmount-Wim /MountDir:"$winpe_root\mount" /Commit

Write-Host "Creating ISO from WinPE"
# Chain run of DandISetEnv.bat and Makewinpemedia.cmd, so the variables are set for the Makewinpemedia.cmd command
$cmdCommands = "call `"$adk_path\Deployment Tools\DandISetEnv.bat`" & Makewinpemedia.cmd /iso /f $winpe_root $artefects_path\WinPE_X64.iso"
Start-Process "cmd.exe" -ArgumentList "/c $cmdCommands" -NoNewWindow -Wait

# Copy boot.wim to the artefacts folder
Copy-Item -Path "$winpe_root\media\sources\boot.wim" -Destination $artefacts_path -Force

Write-Host "Finished creating ISO from WinPE"


