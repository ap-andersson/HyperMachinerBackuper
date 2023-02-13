
# Define all Hyper-V machine names that should be backed up
$machines = @('Machine1', 'Machine2', 'Machine3')

# Set location of 7za.exe file
$7zipaPath = "D:\backup\7z2107-extra\x64\7za.exe"

# Seth directory that will be used for Hyper-V export and where ZIP files will be stored (before copying to final backup location)
$LocalBackupPath = "D:\local\backup\storage\"

# Set path to final backup location where ZIP file will be copied to
$RemoteCopyPath = "\\remote-share\for\final\storage\of\zip\"

foreach ( $MachineName in $machines )
{
    $TimeStamp = get-date -f yyyyMMddhhmm
    $Target = $LocalBackupPath + $MachineName + "_" + $TimeStamp
    $Destination = $RemoteCopyPath + $MachineName + "_" + $TimeStamp
    Write-Host "MachineName: " $MachineName
    Write-Host "Target: " $Target
    Write-Host "Destination: " $Destination
    Export-VM -Name $MachineName -Path $Target
    $ZipFilename = $MachineName + "_" + $TimeStamp + ".zip"
    $ZipOutput = $LocalBackupPath
    $ZipFullPath = $ZipOutput + $ZipFilename
    $ZipCommand = "$7zipaPath a -tzip -mmt8 $LocalBackupPath$ZipFilename $Target\*"
    Write-Host "ZipFilename: " $ZipFilename
    Write-Host "ZipOutput: " $ZipOutput
    Write-Host "ZipFullPath: " $ZipFullPath
    Write-Host "ZipCommand: " $ZipCommand
    Invoke-Expression -Command "$ZipCommand"
    New-Item -ItemType directory -Path $Destination
    Copy-Item -Path $LocalBackupPath$ZipFilename -Destination $Destination -Recurse -Force

    Get-ChildItem -Path $Target -Recurse | Remove-Item -force -recurse
    Remove-Item $Target -Force 

    # No removal in this script
    #Remove-Item -Path $LocalBackupPath$ZipFilename
    #Remove-Item $Target -Recurse
}

# Because of no removal of temp files, the user will be informed when backup is done to do it manually
$FileUri = $LocalBackupPath + "msg.txt"
"Hyper-V machines have been backed up. Please check if you need to clean up old backups. The backups (raw and zipped) can be found at $LocalBackupPath. The ZIPed version were backed up to $RemoteCopyPath. " | Out-File -FilePath "$FileUri"
Invoke-Expression -Command "notepad $FileUri"
