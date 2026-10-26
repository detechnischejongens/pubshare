# Check and disable BitLocker before Sysprep
Write-Host "Checking BitLocker status...."

$bitLockerVolume = Get-BitLockerVolume -MountPoint "C:" -ErrorAction SilentlyContinue

if ($null -eq $bitLockerVolume) {
    Write-Host "BitLocker not found on C: - continuing"
} elseif ($bitLockerVolume.VolumeStatus -eq 'FullyDecrypted') {
    Write-Host "BitLocker is not active on C: - continuing"
} else {
    Write-Host "BitLocker is active on C: - VolumeStatus: $($bitLockerVolume.VolumeStatus)"
    Write-Host "Disabling BitLocker..."
    manage-bde -off C:

    # Wait for decryption to complete
    Write-Host "Waiting for decryption to complete..."
    do {
        Start-Sleep -Seconds 15
        $status = Get-BitLockerVolume -MountPoint "C:"
        Write-Host "VolumeStatus: $($status.VolumeStatus) - Percentage encrypted: $($status.EncryptionPercentage)%"
    } while ($status.VolumeStatus -ne 'FullyDecrypted')

    Write-Host "Decryption completed successfully"
    Write-Host "Final BitLocker status:"
    Get-BitLockerVolume -MountPoint "C:" | Select-Object MountPoint, VolumeStatus, EncryptionPercentage, ProtectionStatus | Format-List
}