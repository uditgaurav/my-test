# Use an alpine base image for minimal size
FROM alpine:latest

# Install kubectl and stress-ng
RUN apk add --no-cache curl stress-ng && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/ && \
    apk del curl

# Copy the script into the container
COPY stress_test.sh .
RUN chmod +x stress_test.sh

# Set environment variables for the arguments; these can be overridden at runtime
ENV POD_NAME=podname
ENV NAMESPACE=default
ENV MEMORY_MB=100
ENV DURATION=60

# The script will be our entry point
ENTRYPOINT ["./usr/local/bin/stress_test.sh", "$POD_NAME", "$NAMESPACE", "$MEMORY_MB", "$DURATION"]
