function Get-ProgramsPath {
	return $env:ProgramsPath
}

function Get-DataPath {
	return $env:DataPath
}

function Get-CodePath {
	return $env:CodePath
}

function Get-ServerPath {
	return $env:ServerPath
}

function Get-UserDisplayName {
	return $env:UserDisplayName
}

function Get-EmailAddress {
	return $env:EmailAddress
}

function New-Path {
	param(
		[Parameter(Mandatory=$True,
				   ValueFromPipeline=$True,
				   ValueFromPipelineByPropertyName=$True)]
		[string]$path
	)
	if (!(Test-Path -Path $path)) {
		New-Item -ItemType directory -Path $path
	}
}

function Initialize-ProvisioningPath {
	if ([string]::IsNullOrEmpty((Get-ProgramsPath))) {
		throw 'ProgramsPath not set'
	}
	if ([string]::IsNullOrEmpty((Get-DataPath))) {
		throw 'DataPath not set'
	}
	if ([string]::IsNullOrEmpty((Get-CodePath))) {
		throw 'CodePath not set'
	}
	if ([string]::IsNullOrEmpty((Get-ServerPath))) {
		throw 'ServerPath not set'
	}
	
	New-Path (Get-ProgramsPath) > $null
	New-Path (Get-DataPath) > $null
	New-Path (Get-CodePath) > $null
	New-Path (Get-ServerPath) > $null
}

function Resolve-Error ($ErrorRecord=$Error[0])
{
   $ErrorRecord | Format-List * -Force
   $ErrorRecord.InvocationInfo |Format-List *
   $Exception = $ErrorRecord.Exception
   for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException)) {
		"$i" * 80
		$Exception |Format-List * -Force
   }
   throw $Exception
}

function Request-DownloadAsString {
	param(
		[Parameter(Mandatory=$True,
				   ValueFromPipeline=$True,
				   ValueFromPipelineByPropertyName=$True)]
		[string]$source
	)
	Write-Host "Downloading $source as String"
	
	$webclient = New-Object System.Net.WebClient
	return $webclient.DownloadString($source)
}

function Confirm-ScoopInstalled {
	$ScoopLocation = Join-Path (Get-ProgramsPath) '\apps\scoop\current\bin\scoop.ps1'
	return Test-Path -Path $ScoopLocation 
}

function Install-Scoop {
	$env:SCOOP = (Get-ProgramsPath)
	$env:SCOOP_GLOBAL = (Get-ServerPath)
	[Environment]::SetEnvironmentVariable("SCOOP", $env:SCOOP, "User")
	[Environment]::SetEnvironmentVariable("SCOOP_GLOBAL", $env:SCOOP_GLOBAL, "User")

	if ((Confirm-ScoopInstalled) -eq $false) {
		Write-Host 'Installing Scoop'

		$ScoopCmd = (Request-DownloadAsString -Source 'https://get.scoop.sh')
		Invoke-Expression $ScoopCmd
	}
	
	if (-not ($env:Path.ToLower().Contains("shims"))) {
		$currentPath = $env:Path
		$shimsPath = Join-Path (Get-ProgramsPath) "shims"
		[Environment]::SetEnvironmentVariable("PATH", "$currentPath;$shimsPath")
	}
}

function Install-Git {
	scoop install git
	$displayName = Get-UserDisplayName
	$email = Get-EmailAddress
	git config --global core.autocrlf true
	git config --global user.name "$displayName"
	git config --global user.email "$email"
}

function Install-Eclipse {
	scoop install eclipse-kepler

	$EclipsePath = (Join-Path(Get-ProgramsPath) '/eclipse-kepler/4.3.1')
	$EclipseP2 = 'org.eclipse.equinox.p2.director'
	$EclipseRepo = 'http://download.eclipse.org/releases/kepler/'
	eclipse -nosplash -application $EclipseP2 -repository $EclipseRepo -destination $EclipsePath -installIU org.eclipse.egit.feature.group
	eclipse -nosplash -application $EclipseP2 -repository 'http://download.jboss.org/drools/release/6.0.0.Final/org.drools.updatesite' -destination $EclipsePath -installIU org.drools.eclipse.feature.feature.group
}

function Configure-Console {
	scoop install concfg
	concfg import -n solarized
	concfg clean
}

function Install-Java7 {
	scoop install java7
}

Export-ModuleMember 'Get-ProgramsPath'
Export-ModuleMember 'Get-DataPath'
Export-ModuleMember 'Get-CodePath'
Export-ModuleMember 'Get-UserDisplayName'
Export-ModuleMember 'Get-EmailAddress'
Export-ModuleMember 'New-Path'
Export-ModuleMember 'Initialize-ProvisioningPath'
Export-ModuleMember 'Resolve-Error'
Export-ModuleMember 'Request-DownloadAsString'
Export-ModuleMember 'Confirm-ScoopInstalled'
Export-ModuleMember 'Install-Scoop'
Export-ModuleMember 'Install-Git'
Export-ModuleMember 'Install-Eclipse'
Export-ModuleMember 'Configure-Console'
