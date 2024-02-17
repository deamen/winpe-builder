param (
    [Parameter(Mandatory=$true)]
    [string]$isoPath
)

# Attempt to mount the ISO and capture the mount result
$mountResult = Mount-DiskImage -ImagePath $isoPath -PassThru -ErrorAction SilentlyContinue

if ($mountResult) {
    # If mounted successfully, get the volume information directly from the mount result
    $volumeInfo = Get-Volume -DiskImage $mountResult

    if ($volumeInfo) {
        # Return the drive letter as output
        $volumeInfo.DriveLetter
    } else {
        Write-Error "Failed to find the volume for the mounted ISO."
    }
} else {
    Write-Error "The ISO is either already mounted, or the specified path is incorrect."
}
