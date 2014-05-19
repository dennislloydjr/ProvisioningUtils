Import-Module .\ProvisioningFunctions.psm1
Import-Module .\DecryptPropertiesUtil.psm1

. .\SetEnvironmentVariables.ps1

function Install-Mysql([SecureString] $EncryptionKey) {
	scoop install mysql
	$MySqlHome = $env:MYSQL_HOME
	$MySqlData = (Join-Path (Get-DataPath) "mysql") -replace "\\", "/"
	New-Path $MySqlData > $null
	$MySqlIniFile = (Join-Path $MySqlData "my.ini") -replace "\\", "/"
	@"
[mysqld]
basedir=$MySqlHome
datadir=$MySqlData/data
port=3306
default-storage-engine=InnoDB
"@ | Out-File -FilePath $MySqlIniFile -Encoding 'ASCII' -Force

	if (!(Test-Path "$MySqlHome/data")) {
		Move-Item "$MySqlHome/data" "$MySqlData"
	}
	mysqld --install MySQL --defaults-file=$MySqlIniFile
	net start MySQL
	
	#Secure MySQL installation
	$MySqlRootPassword = Read-EncryptedProperty "configuration.enc.properties" "mysql.root.password" $EncryptionKey
	mysql -u root -e "UPDATE mysql.user SET Password = PASSWORD('$MySqlRootPassword') WHERE User = 'root'; FLUSH PRIVILEGES;"
}

function Install-Stash {
	scoop install atlassian-stash
	$StashHomePath = Join-Path (Get-DataPath) "Stash"
	New-Path $StashHomePath > $null
	[System.Environment]::SetEnvironmentVariable("STASH_HOME", $StashHomePath, "User")
}

$EncryptionKey = Read-Host "Please enter your encryption key" -AsSecureString

Initialize-ProvisioningPath
Install-Scoop
Install-Git

scoop bucket add extras
scoop bucket add devbox https://github.com/dennislloydjr/scoop-bucket-devbox
scoop update

scoop install wget
scoop install perl
scoop install java7

Install-Mysql $EncryptionKey
