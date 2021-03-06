mkdir c:\inetpub\Solodev
cd c:\inetpub\Solodev

echo "" > scmd.bat
echo 'rm Solodev.zip 2> NUL' >> scmd.bat
echo "for /f %%i in ('aws s3 ls solodev-release ^| find /c /v """"') do set /a RELEASE_LENGTH=%%i-1" >> scmd.bat
echo "for /f ""tokens=4"" %%A in ('aws s3 ls solodev-release ^| sort ^| more /T2 +%%RELEASE_LENGTH%%') do set S3_KEY=%%A" >> scmd.bat
echo "aws s3 cp s3://solodev-release/%S3_KEY% c:\inetpub\Solodev\Solodev.zip" >> scmd.bat
echo "cd c:\inetpub\Solodev" >> scmd.bat
echo "iisreset /stop" >> scmd.bat
echo '@powershell Remove-Item -path c:\inetpub\Solodev\new -recurse -ErrorAction Ignore' >> scmd.bat
echo '@powershell Remove-Item -path c:\inetpub\Solodev\old -recurse -ErrorAction Ignore' >> scmd.bat
echo 'mkdir c:\inetpub\Solodev\new' >> scmd.bat
echo 'mkdir c:\inetpub\Solodev\old' >> scmd.bat
echo "7z x Solodev.zip -oc:\inetpub\Solodev\new\ * -r" >> scmd.bat
echo "del c:\inetpub\Solodev\Solodev.zip" >> scmd.bat
echo 'icacls "C:\Windows\Temp" /t /grant Users:F' >> scmd.bat
echo 'icacls "C:\inetpub\Solodev\new" /t /grant Users:F' >> scmd.bat
echo 'if exist "c:\inetpub\Solodev\core\" move core old/' >> scmd.bat
echo 'if exist "c:\inetpub\Solodev\modules\" move modules old/' >> scmd.bat
echo 'if exist "c:\inetpub\Solodev\public\" move public old/' >> scmd.bat
echo 'if exist "c:\inetpub\Solodev\vendor\" move vendor old/' >> scmd.bat
echo 'if exist "c:\inetpub\Solodev\license\" move license old/' >> scmd.bat
echo 'if exist "c:\inetpub\Solodev\tests\" move tests old/' >> scmd.bat
echo 'if exist "c:\inetpub\Solodev\composer.json" move composer.json old/' >> scmd.bat
echo 'if exist "c:\inetpub\Solodev\composer.lock" move composer.lock old/' >> scmd.bat
echo 'if exist "c:\inetpub\Solodev\license.txt" move license.txt old/' >> scmd.bat
echo 'if exist "c:\inetpub\Solodev\version.txt" move version.txt old/' >> scmd.bat
echo "cd new" >> scmd.bat
echo "move core ../" >> scmd.bat
echo "move modules ../" >> scmd.bat
echo "move public ../" >> scmd.bat
echo "move vendor ../" >> scmd.bat
echo "move license ../" >> scmd.bat
echo "move tests ../" >> scmd.bat
echo "move composer.json ../" >> scmd.bat
echo "move composer.lock ../" >> scmd.bat
echo "move license.txt ../" >> scmd.bat
echo "move version.txt ../" >> scmd.bat
echo "cd ../" >> scmd.bat
echo "iisreset /start" >> scmd.bat
echo "php core/update.php" >> scmd.bat

$contents = Get-Content scmd.bat
Out-File -InputObject $contents -Encoding ASCII scmd.bat

c:\inetpub\Solodev\scmd.bat