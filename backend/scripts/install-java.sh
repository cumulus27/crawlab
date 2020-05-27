#!/bin/bash

# lock global
touch /tmp/install.lock

# lock
touch /tmp/install-java.lock

# install java
yum makecache fast
yum install java-1.8.0-openjdk-devel

ln -s /usr/bin/java /usr/local/bin/java

# unlock
rm /tmp/install-java.lock

# unlock global
rm /tmp/install.lock
