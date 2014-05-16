Import-Module .\ProvisioningFunctions.psm1
Import-Module .\DecryptPropertiesUtil.psm1

function Install-Mysql {
	scoop install mysql --global
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
	scoop install atlassian-stash --global
	$StashHomePath = Join-Path (Get-DataPath) "Stash"
	New-Path $StashHomePath > $null
	[System.Environment]::SetEnvironmentVariable("STASH_HOME", $StashHomePath, "User")
}


Initialize-ProvisioningPath
Install-Scoop
scoop install 7Zip --global
scoop install git --global

scoop bucket add extras
scoop bucket add devbox https://github.com/dennislloydjr/scoop-bucket-devbox
scoop update

scoop install wget --global
scoop install perl --global
scoop install java7 --global

Install-Mysql
