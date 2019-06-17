@echo off
echo ---------------------
echo IMPORTANT!! DO NOT CLOSE!!
echo Please Wait - Initializing App
echo ---------------------

iisreset /stop

cd c:\inetpub\Solodev

mkdir Solodev\clients\solodev
copy Solodev\core\aws\Client_Settings.xml Solodev\clients\solodev

icacls "c:\inetpub\Solodev" /t /grant Users:F

@powershell invoke-restmethod -uri http://169.254.169.254/latest/meta-data/instance-id > instance_id.txt
set /p EC2_INSTANCE_ID=<instance_id.txt
del instance_id.txt

echo sql_mode=NO_ENGINE_SUBSTITUTION >> C:\tools\mysql\current\my.ini
net stop MySQL
net start MySQL
C:\tools\mysql\current\bin\mysql.exe -uroot -e "CREATE DATABASE solodev" 
C:\tools\mysql\current\bin\mysql.exe -uroot -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('%EC2_INSTANCE_ID%');"

set MONGO_DIR=C:\Program Files\MongoDB\Server\3.4

mkdir "%MONGO_DIR%\data\db"
mkdir "%MONGO_DIR%\log"
(
echo logpath=%MONGO_DIR%\log\mongo.log 
echo dbpath=%MONGO_DIR%\data\db
) > "%MONGO_DIR%\mongod.cfg"
"%MONGO_DIR%\bin\mongod.exe" --config "%MONGO_DIR%\mongod.cfg" --install
net start MongoDB
"%MONGO_DIR%\bin\mongo.exe" solodev_views --eval "db.createUser({\"user\": \"root\", \"pwd\": \"%EC2_INSTANCE_ID%\", \"roles\": [ { role: \"readWrite\", db: \"solodev_views\" } ] })"

cd c:\inetpub\Solodev\clients\solodev\
@powershell "(Get-Content Client_Settings.xml) | ForEach-Object { $_ -replace 'REPLACE_WITH_DBHOST', 'localhost' } | Set-Content Client_Settings.xml"
@powershell "(Get-Content Client_Settings.xml) | ForEach-Object { $_ -replace 'REPLACE_WITH_MONGOHOST', 'localhost' } | Set-Content Client_Settings.xml"
@powershell "(Get-Content Client_Settings.xml) | ForEach-Object { $_ -replace 'REPLACE_WITH_DATABASE', 'solodev' } | Set-Content Client_Settings.xml"
@powershell "(Get-Content Client_Settings.xml) | ForEach-Object { $_ -replace 'REPLACE_WITH_DBUSER', 'root'} | Set-Content Client_Settings.xml"
@powershell "(Get-Content Client_Settings.xml) | ForEach-Object { $_ -replace 'REPLACE_WITH_DBPASSWORD', '%EC2_INSTANCE_ID%' } | Set-Content Client_Settings.xml"

C:\Windows\System32\inetsrv\appcmd.exe delete site "Default Web Site"
C:\Windows\System32\inetsrv\appcmd.exe add site /name:"Solodev" /id:1 /physicalPath:"c:\inetpub\Solodev\public\www"
C:\Windows\System32\inetsrv\appcmd.exe set site /site.name:Solodev /+bindings.[protocol='http',bindingInformation='*:80:']
C:\Windows\System32\inetsrv\appcmd.exe add vdir /app.name:"Solodev/" / /path:"/api" /physicalPath:"c:\inetpub\Solodev\core\api"
C:\Windows\System32\inetsrv\appcmd.exe add vdir /app.name:"Solodev/" / /path:"/CK" /physicalPath:"c:\inetpub\Solodev\public\www\node_modules\ckeditor-full"
C:\Windows\System32\inetsrv\appcmd.exe add vdir /app.name:"Solodev/" / /path:"/core" /physicalPath:"c:\inetpub\Solodev\core\html_core"

C:\Windows\System32\inetsrv\appcmd.exe stop site /site.name:Solodev
C:\Windows\System32\inetsrv\appcmd.exe start site /site.name:Solodev

icacls "c:\inetpub\Solodev" /t /grant Users:F
icacls "C:\Windows\Temp" /grant Users:F
icacls "C:\Windows\System32\inetsrv\config" /t /grant IUSR:F

"C:\tools\php\php.exe" c:\inetpub\Solodev\core\update.php solodev %EC2_INSTANCE_ID%
icacls "c:\inetpub\Solodev" /t /grant Users:F

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
echo oLink.IconLocation = "c:\inetpub\Solodev\public\www\assets\images\solodev.ico, 0" >> CreateShortcut.vbs
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
