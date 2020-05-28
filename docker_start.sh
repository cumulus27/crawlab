#!/bin/bash

# script set in background
setsid /app/docker_init.sh > back_output.txt &

exec /usr/sbin/init
