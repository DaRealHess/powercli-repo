Import-module .\EncryptedvMotion.psm1
$EncryptionConfigs=Get-vMotionEncryptionConfig -VM (Get-VM)
foreach ($EncryptionConfig in $EncryptionConfigs)
{
$Status=$EncryptionConfig.vMotionEncryption
$Name=$EncryptionConfig.Name
if( $Status -ne "disabled") {Set-vMotionEncryptionConfig -VM (get-vm $Name) -Encryption disabled}
}
