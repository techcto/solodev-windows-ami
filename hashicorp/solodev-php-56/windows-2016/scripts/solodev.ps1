mkdir c:\inetpub\Solodev

$key = Get-S3Object -BucketName solodev-release | Sort-Object LastModified -Descending | Select-Object -First 1 | select Key
Copy-S3Object -BucketName solodev-release -Key $key."Key" -LocalFile c:\inetpub\Solodev\Solodev.zip

cd c:\inetpub\Solodev
7z x Solodev.zip
del Solodev.zip