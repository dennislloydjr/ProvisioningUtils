. '.\_Common.ps1'

Describe "Initialize-ProvisioningPath" {
	Context 'When path environment setup' {
		Mock Get-ProgramsPath { return 'TestDrive:\z\p' }
		Mock Get-DataPath { return 'TestDrive:\z\d' }
		Mock Get-CodePath { return 'TestDrive:\z\c' }
		Mock Get-ServerPath { return 'TestDrive:\z\s' }
		
		$result = Initialize-ProvisioningPath
		
		It "should create a 'z' folder" {
			Test-Path 'TestDrive:\z' | Should Be True
		}
		It "should create a programs folder" {
			Test-Path 'TestDrive:\z\p' | Should Be True
		}
		It "should create a code folder" {
			Test-Path 'TestDrive:\z\c' | Should Be True
		}
		It "should create a data folder" {
			Test-Path 'TestDrive:\z\d' | Should Be True
		}
		It "should create a server folder" {
			Test-Path 'TestDrive:\z\s' | Should Be True
		}
		It "should return null" {
			$result | Should Be $null
		}
	}
	
	Context 'When path environment not setup' {
		Mock Get-ProgramsPath { return '' }
		Mock Get-DataPath { return $null }
		Mock Get-CodePath { return $null }
		
		It 'should raise an error' {
			{ Initialize-ProvisioningPath } | Should Throw "ProgramsPath not set"
		}
	}
}

Describe "New-Path" {
	Context "When path exists" {
		New-Item -ItemType directory -Path 'TestDrive:\z' > $null
		Mock New-Item {}
		
		$result = New-Path -path 'TestDrive:\z'
		
		It "should not create path" {
			Assert-MockCalled New-Item -Times 0
		}
		It "should return null" {
			$result | Should Be $null
		}
	}

	Context "When path does not exist" {
		$result = New-Path -path 'TestDrive:\z'
		
		It "should create path" {
			Test-Path 'TestDrive:\z' | Should Be True
		}
		It "should return path" {
			$result | Should Be (Convert-Path 'TestDrive:\z')
		}
	}
}

Describe "Confirm-ScoopInstalled" {
	Context "When Scoop does not exist" {
		Mock Get-ProgramsPath {return 'TestDrive:/z'}
		Mock Test-Path {return $False} -ParameterFilter {$path -eq 'TestDrive:\z\apps\scoop\current\bin\scoop.ps1'}
		
		$scoopInstalled = Confirm-ScoopInstalled
		It "should return false" {
			$scoopInstalled | Should Be $False
		}
	}

	Context "When Scoop exists" {
		Mock Get-ProgramsPath {return 'TestDrive:/z'}
		Mock Test-Path {return $True} -ParameterFilter {$path -eq 'TestDrive:\z\apps\scoop\current\bin\scoop.ps1'}
		
		$scoopInstalled = Confirm-ScoopInstalled
		It "should return true" {
			$scoopInstalled | Should Be $True
		}
	}
}

function StubbedFunction {}  # Stub function to call from the "downloaded" scoop core

Describe "Install-Scoop" {
	Mock Confirm-ScoopInstalled {return $false}
	Mock StubbedFunction
	Mock Request-DownloadAsString {return "StubbedFunction"} -ParameterFilter {$source -eq 'https://get.scoop.sh'}
	
	Install-Scoop
	It "Should execute scoop core script" {
		Assert-MockCalled StubbedFunction
	}
	
	It "Should add shims to path" {
		$env:Path | Should Match "shims"
	}
}