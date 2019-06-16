@echo off
echo ---------------------
echo Installing Base
echo ---------------------

@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

choco install IIS-WebServerRole -source windowsfeatures
choco install IIS-ISAPIFilter -source windowsfeatures
choco install IIS-ISAPIExtensions -source windowsfeatures
choco install IIS-NetFxExtensibility -source windowsfeatures
choco install IIS-CGI -source windowsfeatures
choco install urlrewrite -y
choco install vcredist2012 -y
choco install vcredist2013 -y
choco install awscli -y
choco install nodejs-lts -y
choco install googlechrome -y
