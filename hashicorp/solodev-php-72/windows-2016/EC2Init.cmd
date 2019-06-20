@echo off
echo ---------------------
echo IMPORTANT!! DO NOT CLOSE!!
echo Please Wait - Initializing App
echo ---------------------

iisreset /stop
mkdir C:\inetpub\Solodev

cd C:\inetpub\Solodev

mkdir tmp
echo installing... >> tmp\app.log
mkdir clients\solodev

mkdir clients\solodev\jwt
openssl genrsa -passout pass:ocoa -out clients\solodev\jwt\private.pem 4096
openssl rsa -pubout -passin pass:ocoa -in clients\solodev\jwt\private.pem -out clients\solodev\jwt\public.pem
REM ssh-keygen -t rsa -b 4096 -f jwt\private -P ocoa
REM ren jwt\private private.pem
REM ren jwt\private.pub public.pem

icacls "C:\inetpub\Solodev" /t /grant Users:F

@powershell invoke-restmethod -uri http://169.254.169.254/latest/meta-data/instance-id > instance_id.txt
set /p EC2_INSTANCE_ID=<instance_id.txt
del instance_id.txt

sqlcmd -S .\SQLEXPRESS -Q "CREATE DATABASE solodev"
sqlcmd -S .\SQLEXPRESS -Q "ALTER LOGIN sa ENABLE"
sqlcmd -S .\SQLEXPRESS -Q "ALTER LOGIN sa WITH PASSWORD = '%EC2_INSTANCE_ID%'"
REM sqlcmd -S .\SQLEXPRESS -Q "CREATE LOGIN root WITH PASSWORD = '%EC2_INSTANCE_ID%'"
REM sqlcmd -S .\SQLEXPRESS -Q "CREATE USER root FOR LOGIN root"
REM sqlcmd -S .\SQLEXPRESS -Q "ALTER LOGIN root ENABLE"
sqlcmd -S .\SQLEXPRESS -Q "EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE',N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2"

net stop MSSQL$SQLEXPRESS
net start MSSQL$SQLEXPRESS

set MONGO_DIR=C:\Program Files\MongoDB\Server\3.4
set MONGO_DATA_DIR=C:\Mongo

cd %MONGO_DIR%
mkdir "%MONGO_DATA_DIR%\data\db"
mkdir "%MONGO_DATA_DIR%\log"
(
echo logpath=%MONGO_DATA_DIR%\log\mongo.log 
echo dbpath=%MONGO_DATA_DIR%\data\db
) > "%MONGO_DIR%\mongod.cfg"
cd bin
mongod --config "%MONGO_DIR%\mongod.cfg" --install
net start MongoDB
mongo solodev_views --eval "db.createUser({\"user\": \"root\", \"pwd\": \"%EC2_INSTANCE_ID%\", \"roles\": [ { role: \"readWrite\", db: \"solodev_views\" } ] })"

cd C:\inetpub\Solodev\public\www
(
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<configuration^>^<system.webServer^>^<rewrite^>^<rules^>
echo ^<rule name="slim" patternSyntax="Wildcard"^>^<match url="*" /^>
echo ^<conditions^>
echo ^<add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" /^>
echo ^<add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" /^>
echo ^</conditions^>
echo ^<action type="Rewrite" url="app.php" /^>
echo ^</rule^>^</rules^>^</rewrite^>^</system.webServer^>^</configuration^>
) > web.config

cd C:\inetpub\Solodev\clients\solodev\
(
echo DB_DATABASE=REPLACE_WITH_DATABASE
echo DB_USER=REPLACE_WITH_DBUSER
echo DB_PASSWORD=REPLACE_WITH_DBPASSWORD
echo DB_HOST=REPLACE_WITH_DBHOST
echo DBMS=mssqlnative
echo MONGO_HOST=REPLACE_WITH_MONGOHOST:27017
echo IS_ISV=
) > .env
@powershell "(Get-Content .env) | ForEach-Object { $_ -replace 'REPLACE_WITH_DBHOST', '.\SQLEXPRESS' } | Set-Content .env"
@powershell "(Get-Content .env) | ForEach-Object { $_ -replace 'REPLACE_WITH_MONGOHOST', 'localhost' } | Set-Content .env"
@powershell "(Get-Content .env) | ForEach-Object { $_ -replace 'REPLACE_WITH_DATABASE', 'solodev' } | Set-Content .env"
@powershell "(Get-Content .env) | ForEach-Object { $_ -replace 'REPLACE_WITH_DBUSER', 'sa'} | Set-Content .env"
@powershell "(Get-Content .env) | ForEach-Object { $_ -replace 'REPLACE_WITH_DBPASSWORD', '%EC2_INSTANCE_ID%' } | Set-Content .env"

C:\Windows\System32\inetsrv\appcmd.exe delete site "Default Web Site"
C:\Windows\System32\inetsrv\appcmd.exe add site /name:"Solodev" /id:1 /physicalPath:"C:\inetpub\Solodev\public\www"
C:\Windows\System32\inetsrv\appcmd.exe set site /site.name:Solodev /+bindings.[protocol='http',bindingInformation='*:80:']
C:\Windows\System32\inetsrv\appcmd.exe add vdir /app.name:"Solodev/" / /path:"/api" /physicalPath:"C:\inetpub\Solodev\core\api"
C:\Windows\System32\inetsrv\appcmd.exe add vdir /app.name:"Solodev/" / /path:"/CK" /physicalPath:"C:\inetpub\Solodev\public\www\node_modules\ckeditor-full"
C:\Windows\System32\inetsrv\appcmd.exe add vdir /app.name:"Solodev/" / /path:"/core" /physicalPath:"C:\inetpub\Solodev\core\html_core"
C:\Windows\System32\inetsrv\appcmd.exe stop site /site.name:Solodev
C:\Windows\System32\inetsrv\appcmd.exe start site /site.name:Solodev

icacls "C:\inetpub\Solodev" /t /grant Users:F
icacls "C:\Windows\Temp" /grant Users:F
icacls "C:\Windows\System32\inetsrv\config" /t /grant IUSR:F

"C:\tools\php\php.exe" C:\inetpub\Solodev\core\update.php solodev %EC2_INSTANCE_ID%
icacls "C:\inetpub\Solodev" /t /grant Users:F

iisreset /start

echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
echo sLinkFile = "C:\Users\Administrator\Desktop\IIS Manager.lnk" >> CreateShortcut.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "%windir%\system32\inetsrv\InetMgr.exe" >> CreateShortcut.vbs
echo oLink.Save >> CreateShortcut.vbs
cscript CreateShortcut.vbs
del CreateShortcut.vbs

echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
echo sLinkFile = "C:\Users\Administrator\Desktop\Solodev Admin.lnk" >> CreateShortcut.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" >> CreateShortcut.vbs
echo oLink.Arguments = "localhost --profile-directory=Default " >> CreateShortcut.vbs
echo oLink.IconLocation = "C:\inetpub\Solodev\public\www\favicon.ico, 0" >> CreateShortcut.vbs
echo oLink.Save >> CreateShortcut.vbs
cscript CreateShortcut.vbs
del CreateShortcut.vbs

echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
echo sLinkFile = "C:\Users\Administrator\Desktop\Solodev Quick Start Guide.lnk" >> CreateShortcut.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" >> CreateShortcut.vbs
echo oLink.Arguments = "solodev.zendesk.com/hc/en-us/sections/206208667-Quick-Start-Guide --profile-directory=Default " >> CreateShortcut.vbs
echo oLink.Save >> CreateShortcut.vbs
cscript CreateShortcut.vbs
del CreateShortcut.vbs

del "C:\Program Files\Amazon\Ec2ConfigService\Scripts\EC2Init.cmd"
