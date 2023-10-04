#!/bin/bash

cleanup() {
    echo "Received abort signal. Cleaning up..."
    pkill -f stress-ng
    exit 1
}

# Handle abort signals
trap 'cleanup' SIGINT SIGTERM

# Check if we have the required arguments
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <pod_name> <namespace> <memory_in_mb> <time_in_seconds>"
    exit 1
fi

POD_NAME=$1
NAMESPACE=$2
MEMORY_MB=$3
DURATION=$4

# Get the PID of the container's main process. 
# This approach assumes the main process is the one with PID 1 from the container's perspective.
PID=$(kubectl exec -n $NAMESPACE $POD_NAME -- ps -o pid= -p 1)

# If the PID retrieval fails, exit
if [ -z "$PID" ]; then
    echo "Failed to get the PID of the container's main process."
    exit 1
fi

# Using nsenter to run stress-ng within the container's memory namespace but outside of the container
nsenter -t $PID -m stress-ng --vm 1 --vm-bytes ${MEMORY_MB}M --timeout ${DURATION}s &

# Wait for the stress-ng command to complete
wait $!

echo "Stress test completed."
