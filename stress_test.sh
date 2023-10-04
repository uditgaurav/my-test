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

# Start the stress process in the background with stress-ng
stress-ng --vm 1 --vm-bytes ${MEMORY_MB}M --timeout ${DURATION}s &

# Get the PID of the stress-ng process
STRESS_PID=$!

# Let's wait a little to make sure the process started
sleep 0.5

# Find the cgroup of the target container
# This step is crucial, and you'll need to adjust the path if your Kubernetes setup has a different cgroup layout.
CGROUP_PATH=$(kubectl describe pod $POD_NAME -n $NAMESPACE | grep -E "Memory cgroup" | awk '{print $NF}')

# If the cgroup path retrieval fails, exit
if [ -z "$CGROUP_PATH" ]; then
    echo "Failed to get the cgroup path of the container."
    exit 1
fi

# Add the stress-ng process to the cgroup of the target container
echo $STRESS_PID >> /sys/fs/cgroup/memory${CGROUP_PATH}/tasks

# Wait for the stress-ng command to complete
wait $STRESS_PID

echo "Stress test completed."
