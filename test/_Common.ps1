$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$src = Join-Path (Split-Path $here) 'src'

Get-ChildItem -Path $src -Recurse |
				Where-Object {($_.Name -like '*.psm1')} |
				% { 
	$codeFile = Join-Path $_.Directory $_.Name
	
	$code = Get-Content $codeFile | Out-String
	Invoke-Expression $code
}