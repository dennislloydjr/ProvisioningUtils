Import-Module .\ProvisioningFunctions.psm1
Import-Module .\DecryptPropertiesUtil.psm1

. .\SetEnvironmentVariables.ps1

function Install-Mysql {
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

	Move-Item "$MySqlHome/data" "$MySqlData"
	mysqld --install MySQL --defaults-file=$MySqlIniFile
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
Install-Git

scoop bucket add extras
scoop bucket add devbox https://github.com/dennislloydjr/scoop-bucket-devbox
scoop update

scoop install wget
scoop install perl
scoop install java7

Install-Mysql
