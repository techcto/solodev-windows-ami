@echo off
echo ---------------------
echo Installing PHP
echo ---------------------

choco install php -version 7.2.19 -y --params '"/InstallDir:c:\tools\php"'

SET PHP_DIR=C:\tools\php

@powershell Invoke-WebRequest -OutFile ioncube.zip https://downloads.ioncube.com/loader_downloads/ioncube_loaders_win_nonts_vc15_x86-64.zip
7z x ioncube.zip
copy /Y ioncube\ioncube_loader_win_7.2.dll "%PHP_DIR%\ext" 
rd /s /q ioncube
del ioncube.zip

@powershell [Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -OutFile mongodb.zip http://windows.php.net/downloads/pecl/releases/mongodb/1.5.3/php_mongodb-1.5.3-5.6-nts-vc11-x86.zip
copy /Y "%PHP_DIR%\php.ini-production" "%PHP_DIR%\php.ini" 

(
echo [SolodevSpecific]
echo short_open_tag=On
echo.
echo [WebPIChanges]
echo error_log=C:\Windows\Temp\PHP72_errors.log
echo upload_tmp_dir=C:\Windows\Temp
echo session.save_path=C:\Windows\Temp
echo cgi.force_redirect=0
echo cgi.fix_pathinfo=1
echo fastcgi.impersonate=1
echo fastcgi.logging=0
echo max_execution_time=300
echo memory_limit = 512M
echo date.timezone=America/New_York
echo extension_dir="%PHP_DIR%\ext"
echo.
echo [ExtensionList]
echo extension=php_sqlsrv.dll
echo extension=php_pdo_sqlsrv.dll
REM echo extension=php_mysql.dll
REM echo extension=php_mysqli.dll
echo extension=php_mbstring.dll
echo extension=php_gd2.dll
echo extension=php_gettext.dll
echo extension=php_curl.dll
echo extension=php_exif.dll
echo extension=php_xmlrpc.dll
echo extension=php_openssl.dll
echo extension=php_soap.dll
REM echo extension=php_pdo_mysql.dll
REM echo extension=php_pdo_sqlite.dll
echo extension=php_imap.dll
echo extension=php_tidy.dll
echo extension=php_mongodb.dll
) >> "%PHP_DIR%\php.ini"

echo zend_extension = "%PHP_DIR%\ext\ioncube_loader_win_7.2.dll" >> "%PHP_DIR%\php.ini"

C:\Windows\System32\inetsrv\appcmd.exe set config /section:system.webServer/fastCgi "/+[fullPath='%PHP_DIR%\php-cgi.exe']"
C:\Windows\System32\inetsrv\appcmd.exe set config /section:system.webServer/handlers "/+[name='PHP-Files',path='*.php',verb='GET,HEAD,POST',modules='FastCgiModule',scriptProcessor='%PHP_DIR%\php-cgi.exe',resourceType='Either']"
C:\Windows\System32\inetsrv\appcmd.exe set config /section:system.webServer/handlers "/+[name='STML-Files',path='*.stml',verb='GET,HEAD,POST',modules='FastCgiModule',scriptProcessor='%PHP_DIR%\php-cgi.exe',resourceType='Either']"
C:\Windows\System32\inetsrv\appcmd.exe set config /section:system.webServer/defaultDocument "/+files.[value='index.php']"
C:\Windows\System32\inetsrv\appcmd.exe set config /section:system.webServer/defaultDocument "/+files.[value='index.stml']"
C:\Windows\System32\inetsrv\appcmd.exe set config /section:system.webServer/defaultDocument "/+files.[value='app.php']"
