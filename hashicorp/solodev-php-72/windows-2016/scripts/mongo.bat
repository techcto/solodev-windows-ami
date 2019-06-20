@echo off
echo ---------------------
echo Installing Mongo
echo ---------------------

choco install mongodb -version 3.4.7 -y

SET PHP_DIR=C:\tools\php

@powershell [Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -OutFile mongodb.zip https://windows.php.net/downloads/pecl/releases/mongodb/1.5.5/php_mongodb-1.5.5-7.2-nts-vc15-x64.zip
mkdir mongodb
7z x -omongodb mongodb.zip
copy /Y mongodb\php_mongodb.dll "%PHP_DIR%\ext
rd /s /q mongodb
del mongodb.zip
