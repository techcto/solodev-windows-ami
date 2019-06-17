@echo off
echo ---------------------
echo Installing Base
echo ---------------------

@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

choco install IIS-WebServerRole IIS-ISAPIFilter IIS-ISAPIExtensions IIS-CGI --source WindowsFeatures
choco install urlrewrite vcredist2012 vcredist2013 awscli googlechrome 7zip openssl.light -y

SET PHP_DIR=C:\tools\php