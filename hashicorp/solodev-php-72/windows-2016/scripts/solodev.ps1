mkdir c:\inetpub\Solodev 2> NUL
cd c:\inetpub\Solodev

iisreset /stop

echo "" > scmd.bat
echo "for /f %%i in ('aws s3 ls solodev-release ^| find /c /v """"') do set /a RELEASE_LENGTH=%%i-1" >> scmd.bat
echo "for /f ""tokens=4"" %%A in ('aws s3 ls solodev-release ^| sort ^| more /T2 +%%RELEASE_LENGTH%%') do set S3_KEY=%%A" >> scmd.bat
echo "aws s3 cp s3://solodev-release/%S3_KEY% c:\inetpub\Solodev\Solodev.zip" >> scmd.bat
echo "cd c:\inetpub\Solodev" >> scmd.bat
echo '@powershell Remove-Item -path c:\inetpub\Solodev\new -recurse -ErrorAction Ignore' >> scmd.bat
echo '@powershell Remove-Item -path c:\inetpub\Solodev\old -recurse -ErrorAction Ignore' >> scmd.bat
echo 'mkdir c:\inetpub\Solodev\new 2> NUL' >> scmd.bat
echo 'mkdir c:\inetpub\Solodev\old 2> NUL' >> scmd.bat
echo 'rm Solodev.zip 2> NUL' >> scmd.bat
echo "7z x Solodev.zip -oc:\inetpub\Solodev\new\ * -r" >> scmd.bat
echo "del c:\inetpub\Solodev\Solodev.zip" >> scmd.bat
echo "move core old/" >> scmd.bat
echo "move modules old/" >> scmd.bat
echo "move public old/" >> scmd.bat
echo "move vendor old/" >> scmd.bat
echo "move license old/" >> scmd.bat
echo "move tests old/" >> scmd.bat
echo "move composer.json old/" >> scmd.bat
echo "move composer.lock old/" >> scmd.bat
echo "move license.txt old/" >> scmd.bat
echo "move version.txt old/" >> scmd.bat
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

$contents = Get-Content scmd.bat
Out-File -InputObject $contents -Encoding ASCII scmd.bat

.\scmd.bat

iisreset /start