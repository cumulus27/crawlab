#!/bin/bash

# script set in background
setsid ./docker_init.sh > back_output.txt &

exec /usr/sbin/init
