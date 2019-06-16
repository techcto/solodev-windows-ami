mkdir c:\Solodev

#Install latest official release of Solodev
mkdir -p /tmp/app
fn="$(aws s3 ls s3://solodev-release | sort | tail -n 1 | awk '{print $4}')"
aws s3 cp s3://solodev-release/$fn c:\Solodev\Solodev.zip

c:\Solodev
ls -alh
7z x Solodev.zip
del Solodev.zip