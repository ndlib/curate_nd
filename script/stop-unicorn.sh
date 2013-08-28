#!/bin/bash

app_root=$(cd $(dirname $0)/.. && pwd)

pid_file="$app_root/tmp/pids/unicorn.pid"

if [ ! -e $pid_file ]; then
    exit "Cannot find unicorn.pid"
fi

PID=$(cat $pid_file)

# does process exist?
if kill -0 $PID; then
    echo "Stopping server at $PID"
    kill -QUIT $PID
else
    echo "Process ID in $pid_file does not exist"
fi

