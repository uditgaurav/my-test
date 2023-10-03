#!/bin/bash

cleanup() {
    echo "Received abort signal. Cleaning up..."
    kubectl exec -n $NAMESPACE $POD_NAME -- pkill -f stress-ng
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

# Get the PID of the container's main process. Assuming it's the first process in the container.
PID=$(kubectl exec -n $NAMESPACE $POD_NAME -- ps -e | head -n 2 | tail -n 1 | awk '{print $1}')

# Pause the process inside the container using nsutil
nsutil -t $PID -m -- pause

# Start the stress process in the background with stress-ng
stress-ng --vm 1 --vm-bytes ${MEMORY_MB}M --timeout ${DURATION}s --pause &

# Get the PID of the stress-ng process
STRESS_PID=$!

# Add the stress-ng process to the cgroup of the target container
# Assuming you are using cgroup v1 and the cgroup paths have to be correctly identified
echo $STRESS_PID >> /sys/fs/cgroup/memory/kubernetes/$NAMESPACE/$POD_NAME/tasks

# Wait for the process to start before sending the resume signal
sleep 0.7

# Resume the paused stress-ng process
kill -CONT $STRESS_PID

# Wait for the stress-ng command to complete
wait $STRESS_PID

echo "Stress test completed."
