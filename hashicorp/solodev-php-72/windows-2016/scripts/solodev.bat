mkdir c:\Solodev

$key = Get-S3Object -BucketName solodev-release | Sort-Object LastModified -Descending | Select-Object -First 1 | select Key
Copy-S3Object -BucketName solodev-release -Key $key."Key" -LocalFile c:\Solodev\Solodev.zip

cd c:\Solodev
7z x Solodev.zip
del Solodev.zip