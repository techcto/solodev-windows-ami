@echo off
echo ---------------------
echo Installing MSSql
echo ---------------------

choco install sql-server-express

@powershell [Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -OutFile msphpsql.zip https://windows.php.net/downloads/pecl/releases/pdo_sqlsrv/5.6.1/php_pdo_sqlsrv-5.6.1-7.2-nts-vc15-x64.zip
7z x msphpsql.zip -o.\msphpsql
copy /Y msphpsql\php_pdo_sqlsrv.dll "%PHP_DIR%\ext" 
rd /s /q msphpsql
del msphpsql.zip
@powershell [Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -OutFile msphpsql.zip https://windows.php.net/downloads/pecl/releases/sqlsrv/5.6.1/php_sqlsrv-5.6.1-7.2-nts-vc15-x64.zip
7z x msphpsql.zip -o.\msphpsql
copy /Y msphpsql\php_sqlsrv.dll "%PHP_DIR%\ext" 
rd /s /q msphpsql
del msphpsql.zip
