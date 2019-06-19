mkdir c:\inetpub\Solodev
mkdir c:\inetpub\Solodev\old
mkdir c:\inetpub\Solodev\new
cd c:\inetpub\Solodev

iisreset /stop

Remove-Item –path c:\inetpub\Solodev\old –recurse -ErrorAction Ignore

echo "" > solodev.bat
echo "for /f %%i in ('aws s3 ls solodev-release ^| find /c /v """"') do set /a RELEASE_LENGTH=%%i-1" >> solodev.bat
echo "for /f ""tokens=4"" %%A in ('aws s3 ls solodev-release ^| sort ^| more /T2 +%%RELEASE_LENGTH%%') do set S3_KEY=%%A" >> solodev.bat
echo "aws s3 cp s3://solodev-release/%S3_KEY% c:\inetpub\Solodev\Solodev.zip" >> solodev.bat
echo "cd c:\inetpub\Solodev" >> solodev.bat
echo "7z x Solodev.zip -onew/" >> solodev.bat
echo "del c:\inetpub\Solodev\Solodev.zip" >> solodev.bat
echo "mkdir old" >> solodev.bat
echo "move core old" >> solodev.bat
echo "move modules old" >> solodev.bat
echo "move public old" >> solodev.bat
echo "move vendor old" >> solodev.bat
echo "move license old" >> solodev.bat
echo "move tests old" >> solodev.bat
echo "move composer.json old" >> solodev.bat
echo "move composer.lock old" >> solodev.bat
echo "move license.txt old" >> solodev.bat
echo "move version.txt old" >> solodev.bat
echo "move new\* c:\inetpub\Solodev" >> solodev.bat

Remove-Item –path c:\inetpub\Solodev\new –recurse -ErrorAction Ignore

./solodev.bat
./scmd.ps1

iisreset /start