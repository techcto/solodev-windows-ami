mkdir c:\inetpub\Solodev
mkdir c:\inetpub\Solodev\old
mkdir c:\inetpub\Solodev\new
cd c:\inetpub\Solodev

iisreset /stop

Remove-Item –path c:\inetpub\Solodev\old –recurse

echo '' > solodev.ps1
echo '$key = Get-S3Object -BucketName solodev-release | Sort-Object LastModified -Descending | Select-Object -First 1 | select Key' >> solodev.ps1
echo 'Copy-S3Object -BucketName solodev-release -Key $key."Key" -LocalFile c:\inetpub\Solodev\Solodev.zip' >> solodev.ps1
echo "cd c:\inetpub\Solodev" >> solodev.scmd.bat
echo "7z x Solodev.zip -onew/" >> solodev.ps1
echo "del c:\inetpub\Solodev\Solodev.zip" >> solodev.ps1
echo "Remove-Item old -Recurse -ErrorAction Ignore" >> solodev.ps1
echo "mkdir old" >> solodev.ps1
echo "move core old" >> solodev.ps1
echo "move modules old" >> solodev.ps1
echo "move public old" >> solodev.ps1
echo "move vendor old" >> solodev.ps1
echo "move license old" >> solodev.ps1
echo "move tests old" >> solodev.ps1
echo "move composer.json old" >> solodev.ps1
echo "move composer.lock old" >> solodev.ps1
echo "move license.txt old" >> solodev.ps1
echo "move version.txt old" >> solodev.ps1
echo "move new\* c:\inetpub\Solodev" >> solodev.ps1

Remove-Item –path c:\inetpub\Solodev\new –recurse

./solodev.ps1
./scmd.ps1

iisreset /start