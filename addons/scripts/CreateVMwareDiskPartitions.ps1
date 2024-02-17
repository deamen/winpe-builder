# WARNING: This script will modify partitions on the first VMware Virtual disk, potentially erasing all data.

# Get the first VMware Virtual disk
$disk = Get-Disk | Where-Object {$_.FriendlyName -like "*VMware Virtual disk*"} | Sort-Object Number | Select-Object -First 1

if ($null -eq $disk) {
    Write-Error "No VMware Virtual disk found."
    exit
}

$diskNumber = $disk.Number

# Check if the disk is initialized (not 'Raw')
if ($disk.PartitionStyle -ne 'Raw') {
    # Clear all partitions/data from the disk
    Clear-Disk -Number $diskNumber -RemoveData -RemoveOEM -Confirm:$false
    Initialize-Disk -Number $diskNumber -PartitionStyle GPT
} else {
    Write-Host "Disk $diskNumber is uninitialized. Initializing the disk."
    Initialize-Disk -Number $diskNumber -PartitionStyle GPT
}



# Refresh disk info
$disk = Get-Disk -Number $diskNumber

# Calculate sizes for partitions
$sizeForSecondPartition = 20GB
$totalSize = $disk.Size
$sizeForFirstPartition = $totalSize - $sizeForSecondPartition

# Create the first partition
$firstPartition = New-Partition -DiskNumber $diskNumber -Size $sizeForFirstPartition -AssignDriveLetter
if ($firstPartition) {
    $driveLetter = $firstPartition.DriveLetter
    Format-Volume -DriveLetter $driveLetter -FileSystem NTFS -NewFileSystemLabel "PrimaryPartition" -Confirm:$false
    Write-Host "Successfully created and formatted the first partition. Drive letter: $driveLetter"
} else {
    Write-Error "Failed to create the first partition."
    exit
}

# Create the second partition with the remaining space
$secondPartition = New-Partition -DiskNumber $diskNumber -UseMaximumSize -DriveLetter T
if ($secondPartition) {
    $driveLetter = $secondPartition.DriveLetter
    Format-Volume -DriveLetter $driveLetter -FileSystem NTFS -NewFileSystemLabel "SecondaryPartition" -Confirm:$false
    Write-Host "Successfully created and formatted the second partition with the remaining space. Drive letter: $driveLetter"
} else {
    Write-Error "Failed to create the second partition."
}

# Delete the first partition
Remove-Partition -DriveLetter $firstPartition.DriveLetter -Confirm:$false
Write-Host "The first partition has been deleted."