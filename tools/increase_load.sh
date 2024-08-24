#!/bin/bash

# Configuration
NUM_CHILDREN=$1 # Number of child processes to spawn
NUM_REQUESTS=$2 # Number of requests per child
SLEEP=$3        # used to indicate the number of seconds to wait before spawning new process
URL=$4
# Array to store PIDs of child processes
PIDS=()

# Function to handle Ctrl-C (SIGINT)
function cleanup() {
    echo "Caught Ctrl-C, killing all child processes..."
    i=1
    for pid in "${PIDS[@]}"; do
        kill -9 "$pid"
        echo "Killed $i out of ${#PIDS[@]} children"
        i=$(($i + 1))
    done
    exit 1
}

function main() {
    # Trap Ctrl-C (SIGINT) signal
    trap cleanup SIGINT
    # Main loop to spawn children
    for i in $(seq 1 "$NUM_CHILDREN"); do
        send_requests &
        PIDS+=("$!") # Store the PID of the child process
        echo "Created $i out of $NUM_CHILDREN processes"
        sleep $SLEEP # used for gradually increasing the number of concurrent requests
    done

    echo "PIDs of all subprocesses=[${PIDS[@]}]"
    # Wait for all children to complete
    wait
    echo "All requests completed."
}

# Function for each child to send requests
function send_requests() {
    for i in $(seq 1 "$NUM_REQUESTS"); do
        curl -s "$URL"
    done
}

function help() {
    echo "$0 NUM_CHILDREN NUM_REQUESTS SLEEP URL"
    echo "NUM_CHILDREN: number of child processes to create"
    echo "NUM_REQUESTS: number of requests to be sent by each child process"
    echo "SLEEP: number of seconds to wait before spwaning new child process"
    echo "URL: url to send requests to"
    echo "WARNING: Please be careful while selecting value of NUM_CHILDREN, a large value might cause your system to slow down, or even crash in worst case scenario"
}

if [[ $# -ne 0 ]]; then
    main
else
    help
fi


