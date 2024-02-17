# Define the path to the ISO you want to mount
$isoPath = "T:\install.iso"

# Get the full path of the directory containing this script
$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# Construct the path to the script you want to call
$scriptToCall = Join-Path -Path $scriptPath -ChildPath "MountISOAndReturnLetter.ps1"

# Call the script with the constructed path and pass parameters
$driveLetter = & $scriptToCall -isoPath $isoPath

# Check if the drive letter was captured
if ($driveLetter) {
    Write-Host "ISO was mounted to drive ${driveLetter}:"
} else {
    Write-Host "Failed to mount ISO or capture drive letter."
}

# Construct the setup.exe path
$setupPath = Join-Path -Path ${driveLetter}: -ChildPath "setup.exe"

# Check if setup.exe exists at the specified path
if (Test-Path -Path $setupPath) {
    # Execute setup.exe
    Start-Process -FilePath $setupPath
    Write-Host "Starting setup.exe from ${driveLetter}:"
} else {
    Write-Host "setup.exe not found at ${driveLetter}:"
}
