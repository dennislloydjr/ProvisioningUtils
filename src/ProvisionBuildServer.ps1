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
transaction-isolation=READ-COMMITTED
binlog_format=row
"@ | Out-File -FilePath $MySqlIniFile -Encoding 'ASCII' -Force

	if (!(Test-Path "$MySqlHome/data")) {
		Move-Item "$MySqlHome/data" "$MySqlData"
	}
	mysqld --install MySQL --defaults-file=$MySqlIniFile
	net start MySQL
	
	#Secure MySQL installation
	$MySqlRootPassword = Read-EncryptedProperty "configuration.enc.properties" "mysql.root.password" $EncryptionKey
	$MySqlDevboxPassword = Read-EncryptedProperty "configuration.enc.properties" "mysql.devbox.password" $EncryptionKey
	mysql -u root -e "DROP USER ''@'localhost';"
	mysql -u root -e "DROP DATABASE test;"
	mysql -u root -e "CREATE USER 'devbox'@'localhost' IDENTIFIED BY '$MySqlDevboxPassword';"
	mysql -u root -e "UPDATE mysql.user SET Password = PASSWORD('$MySqlRootPassword') WHERE User = 'root'; FLUSH PRIVILEGES;"
}

function Install-Crowd([SecureString] $EncryptionKey) {
	scoop install atlassian-crowd
	$CrowdHomePath = Join-Path (Get-DataPath) "Crowd"
	New-Path $CrowdHomePath > $null
	$Properties = @{
		'crowd.home' = $CrowdHomePath
	}
	$CrowdInitFile = Join-Path ($env:CROWD_INSTALL) 'crowd-webapp\WEB-INF\classes\crowd-init.properties'
	Replace-PropertiesInFile $Properties, $CrowdInitFile
	
	$MySqlRootPassword = Read-EncryptedProperty "configuration.enc.properties" "mysql.root.password" $EncryptionKey
	$MySqlDevboxPassword = Read-EncryptedProperty "configuration.enc.properties" "mysql.devbox.password" $EncryptionKey
	mysql -u root -p $MySqlRootPassword -e "CREATE DATABASE crowd CHARACTER SET UTF8 COLLATE utf8_bin;"
	mysql -u root -p $MySqlRootPassword -e "GRANT ALL PRIVILEGES ON crowd.* TO 'crowduser'@'localhost' IDENTIFIED BY '$MySqlDevboxPassword';"
	
	$MySqlJdbcDriverTarget = Join-Pat ($env:CROWD_INSTALL) 'apache-tomcat\lib'
	wget -Uri 'http://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.6/mysql-connector-java-5.1.6.jar' -OutFile $MySqlJdbcDriverTarget
	
	$CrowdServiceInstaller = Join-Path ($env:CROWD_INSTALL) 'apache-tomcat\bin'
	Invoke-Expression ("$CrowdServiceInstaller install Crowd")
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
