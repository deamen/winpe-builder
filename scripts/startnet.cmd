@Echo OFF
wpeinit
REM Add scripts below the ::: line
REM Examples Calling PowerShell: powershell -executionpolicy Unrestricted -noexit -file ".\scriptname.ps1"
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
PowerShell -ExecutionPolicy Bypass -File "X:\scripts\CreateVMwareDiskPartitions.ps1"
PowerShell -ExecutionPolicy Bypass -File "X:\scripts\DownloadISO.ps1"
PowerShell -ExecutionPolicy Bypass -File "X:\scripts\StartSetup.ps1"