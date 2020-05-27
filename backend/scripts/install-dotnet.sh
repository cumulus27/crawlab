# lock global
touch /tmp/install.lock

# lock
touch /tmp/install-dotnet.lock

rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
yum makecache fast
yum install -y dotnet-sdk-2.1 dotnet-runtime-2.1 aspnetcore-runtime-2.1

# unlock global
rm /tmp/install.lock

# unlock
rm /tmp/install-dotnet.lock
