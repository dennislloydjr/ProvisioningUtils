Import-Module .\ProvisioningFunctions.psm1
Import-Module .\DecryptPropertiesUtil.psm1

. .\SetEnvironmentVariables.ps1

function Install-Mysql {
	scoop install mysql
	$MySqlHome = $env:MYSQL_HOME
	$MySqlData = Join-Path (Get-DataPath) "mysql"
	New-Path $MySqlData > $null
	$MySqlIniFile = Join-Path $MySqlData "my.ini"
	@"
[mysqld]
basedir=$MySqlHome
datadir=$MySqlData
port=3306
default-storage-engine=InnoDB
"@ | Out-File -FilePath $MySqlIniFile -Force

	mysqld --install MySQL --defaults-file="$MySqlIniFile"
	net start MySQL
}

function Install-Stash {
	scoop install atlassian-stash
	$StashHomePath = Join-Path (Get-DataPath) "Stash"
	New-Path $StashHomePath > $null
	[System.Environment]::SetEnvironmentVariable("STASH_HOME", $StashHomePath, "User")
}


Initialize-ProvisioningPath
Install-Scoop
scoop install 7Zip
scoop install git

scoop bucket add extras
scoop bucket add devbox https://github.com/dennislloydjr/scoop-bucket-devbox
scoop update

scoop install wget
scoop install perl
scoop install java7

Install-Mysql
