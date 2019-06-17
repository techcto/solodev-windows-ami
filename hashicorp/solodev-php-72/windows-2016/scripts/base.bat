@echo off
echo ---------------------
echo Installing Base
echo ---------------------

@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

choco install IIS-WebServerRole --source WindowsFeatures
choco install IIS-ISAPIFilter --source WindowsFeatures
choco install IIS-ISAPIExtensions --source WindowsFeatures
REM choco install IIS-NetFxExtensibility --source WindowsFeatures
choco install IIS-CGI --source WindowsFeatures


choco install urlrewrite -y
choco install vcredist2012 -y
choco install vcredist2013 -y
choco install awscli -y
choco install nodejs-lts -y
choco install googlechrome -y
choco install 7zip -y
