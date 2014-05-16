Import-Module .\ProvisioningFunctions.psm1

Initialize-ProvisioningPath
Install-Scoop
scoop install 7Zip
Install-Git
scoop bucket add extras
scoop bucket add devbox https://github.com/dennislloydjr/scoop-bucket-devbox
scoop update

scoop install wget

scoop install java8

scoop install sysinternals
Configure-Console
scoop install coreutils  #Core utils (msys)
scoop install nodejs
scoop install notepadplusplus
scoop install mvn
#scoop install virtual-box
scoop install vagrant
scoop install putty
scoop install winmerge
# Install-Eclipse
