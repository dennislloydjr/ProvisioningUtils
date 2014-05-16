function Decrypt-SecureString($SecureString) {
	$BStr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
	[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BStr)
}

function Read-EncryptedProperty([String] $InputFileName, [String] $PropertyKey) {
	$Properties = Get-Content $InputFileName | ConvertFrom-StringData
	$EncryptionKey = Read-Host "Please enter your encryption key" -AsSecureString
	$EncryptedPassword = $Properties.$PropertyKey
	$PasswordSecureString = ConvertTo-SecureString -String $EncryptedPassword -SecureKey $EncryptionKey
	Decrypt-SecureString $PasswordSecureString
}

Export-ModuleMember 'Decrypt-SecureString'
Export-ModuleMember 'Read-EncryptedProperty'