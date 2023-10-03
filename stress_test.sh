#!/bin/bash

cleanup() {
    echo "Received abort signal. Cleaning up..."
    kubectl exec -n $NAMESPACE $POD_NAME -- rm -f /tmp/stressfile
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

# Exec into the pod and run the stress commands

# Stress Memory using dd
echo "Stressing memory for ${DURATION} seconds..."
kubectl exec -n $NAMESPACE $POD_NAME -- bash -c "dd if=/dev/zero of=/tmp/stressfile bs=1M count=$MEMORY_MB & sleep $DURATION && rm -f /tmp/stressfile" &

# Store the background process PID
BACKGROUND_PID=$!

# If you wish to add CPU stress, consider using a tool like 'stress' or 'stress-ng'
# Example:
# kubectl exec -n $NAMESPACE $POD_NAME -- bash -c "stress --cpu 1 --timeout ${DURATION}s"

# Wait for the commands to complete
wait $BACKGROUND_PID

echo "Stress test completed."
