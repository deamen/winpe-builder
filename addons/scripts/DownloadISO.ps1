param(
    [Parameter(Mandatory=$true)]
    [string]$isoUrl

)

# Get the full path of the directory containing this script
$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# Construct the path to the script you want to call
$scriptToCall = Join-Path -Path $scriptPath -ChildPath "AddPathToSessionEnvironment.ps1"


# Define apps path
$appsPath = "X:\apps"

# Call the script with the constructed path and pass parameters
& $scriptToCall -newPath $appsPath

# Check if aria2c is installed
$aria2cExists = Get-Command "aria2c" -ErrorAction SilentlyContinue
if (-not $aria2cExists) {
    Write-Error "aria2c is not installed. Please install aria2c and try again."
    exit
}

# Prepare aria2c arguments for maximum bandwidth usage
$aria2cArgs = @(
    "--file-allocation=none", # Avoid pre-allocating file space
    "-x 16", # Enable up to 16 connections per server
    "-s 16", # Split the file into 16 parts
    "-k 100M", # Set the size of each part to 100M
    "--max-connection-per-server=16", # Max connections per server
    "--min-split-size=1M", # Minimum split size
    "--console-log-level=info", # Logging level
    "--download-result=full", # Show full download result
    "--dir T:", # Set the download directory to T:
    "-o install.iso", # Output file name
    "`"$isoUrl`"" # ISO URL
)

# Execute aria2c with the constructed arguments
$command = "aria2c " + ($aria2cArgs -join " ")
Invoke-Expression $command

