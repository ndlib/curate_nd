#!/bin/bash

app_root=$(cd $(dirname $0)/.. && pwd)

pid_file="$app_root/tmp/pids/unicorn.pid"

function start_unicorn {
    echo "Starting unicorn"
    $app_root/script/start-unicorn.sh
}

if [ ! -e $pid_file ]; then
    echo "Cannot find unicorn.pid"
    start_unicorn
else
    PID=$(cat $pid_file)

    # does process exist?
    if kill -0 $PID; then
        echo "Signaling server at pid=$PID"
        kill -USR2 $PID
        sleep 10
        echo "Killing old server"
        kill -QUIT $PID
    else
        echo "Process ID in unicorn.pid does not exist"
        start_unicorn
    fi
fi

