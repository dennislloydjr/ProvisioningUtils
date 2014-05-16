Param([String] $InputFileName, [String] $OutputFileName)

function Generate-Password([int] $Length = 20) {
	$PasswordCharacters = 48..57 + 65..90 + 97..122
	Get-Random -Count $Length -Input $PasswordCharacters | % -begin { $aa = $null } -process {$aa += [char]$_} -end {$aa}
}

Write-Host "If you don't have an encryption key, you can use this one: "
Write-Host (Generate-Password -Length 16)

$EncryptionKey = Read-Host "Please enter your encryption key" -AsSecureString

$Properties = Get-Content $InputFileName | ConvertFrom-StringData
Remove-Item $OutputFileName -Force

foreach($PropertyKey in $($Properties.Keys)) {
	$UnencryptedPassword = $Properties.$PropertyKey
	if ([string]::IsNullOrEmpty($UnencryptedPassword)) {
		$UnencryptedPassword = ConvertTo-SecureString -String (Generate-Password) -AsPlainText -Force
	} else {
		$UnencryptedPassword = ConvertTo-SecureString -String $UnencryptedPassword -AsPlainText -Force
	}
	$EncryptedPassword = ConvertFrom-SecureString -SecureString $UnencryptedPassword -SecureKey $EncryptionKey
	Add-Content $OutputFileName ("$PropertyKey=$EncryptedPassword")
}