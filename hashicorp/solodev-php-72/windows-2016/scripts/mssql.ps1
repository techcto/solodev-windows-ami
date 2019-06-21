New-Item -ItemType Directory -Force -Path "${Env:ProgramFiles}\Microsoft SQL Server"
New-Item -ItemType Directory -Force -Path "${Env:ProgramFiles(x86)}\Microsoft SQL Server"
Disable-NtfsCompression -Path "${Env:ProgramFiles}\Microsoft SQL Server"
Disable-NtfsCompression -Path "${Env:ProgramFiles(x86)}\Microsoft SQL Server"
Install-Package -Name 'mssqlserver2014express' -ProviderName 'chocolateyget' -Force
Set-Service -Name 'MSSQL$SQLEXPRESS' -StartupType Automatic
Set-Service -Name 'SQLWriter' -StartupType Automatic