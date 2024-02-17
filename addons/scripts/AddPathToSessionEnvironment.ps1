# AddPathToSessionEnvironment.ps1

param (
    [Parameter(Mandatory=$true)]
    [string]$newPath
)

function Add-PathToSessionEnvironment {
    param (
        [string]$PathToAdd
    )

    # Check if the new path is already in the current session's PATH
    if (-not ($env:PATH -split ';' -contains $PathToAdd)) {
        # If not, add the new path to the current session's PATH
        $env:PATH += ";$PathToAdd"

        Write-Output "Path added successfully to the session's environment."
    } else {
        Write-Output "The path is already in the session's PATH."
    }
}

# Call the function with the newPath parameter
Add-PathToSessionEnvironment -PathToAdd $newPath
