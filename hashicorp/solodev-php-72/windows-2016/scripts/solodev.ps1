mkdir c:\inetpub\Solodev
mkdir c:\inetpub\Solodev\old
mkdir c:\inetpub\Solodev\new
cd c:\inetpub\Solodev

iisreset /stop

Remove-Item –path c:\inetpub\Solodev\old –recurse -ErrorAction Ignore

echo "" > scmd.bat
echo "for /f %%i in ('aws s3 ls solodev-release ^| find /c /v """"') do set /a RELEASE_LENGTH=%%i-1" >> scmd.bat
echo "for /f ""tokens=4"" %%A in ('aws s3 ls solodev-release ^| sort ^| more /T2 +%%RELEASE_LENGTH%%') do set S3_KEY=%%A" >> scmd.bat
echo "aws s3 cp s3://solodev-release/%S3_KEY% c:\inetpub\Solodev\Solodev.zip" >> scmd.bat
echo "cd c:\inetpub\Solodev" >> scmd.bat
echo "7z x Solodev.zip -onew/" >> scmd.bat
echo "del c:\inetpub\Solodev\Solodev.zip" >> scmd.bat
echo "mkdir old" >> scmd.bat
echo "move core old" >> scmd.bat
echo "move modules old" >> scmd.bat
echo "move public old" >> scmd.bat
echo "move vendor old" >> scmd.bat
echo "move license old" >> scmd.bat
echo "move tests old" >> scmd.bat
echo "move composer.json old" >> scmd.bat
echo "move composer.lock old" >> scmd.bat
echo "move license.txt old" >> scmd.bat
echo "move version.txt old" >> scmd.bat
echo "move new\* c:\inetpub\Solodev" >> scmd.bat

Remove-Item –path c:\inetpub\Solodev\new –recurse -ErrorAction Ignore

scmd.bat

iisreset /start