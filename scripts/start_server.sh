#!/bin/bash
set -e

echo "=== Starting deployment script ==="
echo "Working directory: $(pwd)"
echo "Files in current directory:"
ls -la

echo "Files in /opt/app:"
ls -la /opt/app/ || echo "/opt/app/ directory not found"

# Check multiple possible locations for imageDetail.json
IMAGE_DETAIL_FILE=""
if [ -f "./imageDetail.json" ]; then
    IMAGE_DETAIL_FILE="./imageDetail.json"
    echo "Found imageDetail.json in current directory"
elif [ -f "/opt/app/imageDetail.json" ]; then
    IMAGE_DETAIL_FILE="/opt/app/imageDetail.json"
    echo "Found imageDetail.json in /opt/app/"
else
    echo "ERROR: imageDetail.json not found in current directory or /opt/app/"
    echo "Available files:"
    find . -name "*.json" -type f || echo "No JSON files found"
    exit 1
fi

# Read the image URI (without jq to avoid dependency)
echo "Reading image URI from: $IMAGE_DETAIL_FILE"
cat $IMAGE_DETAIL_FILE

# Extract ImageURI without jq
IMAGE_URI=$(grep -o '"ImageURI":"[^"]*"' $IMAGE_DETAIL_FILE | sed 's/"ImageURI":"\(.*\)"/\1/')

if [ -z "$IMAGE_URI" ]; then
    echo "ERROR: Could not extract ImageURI from $IMAGE_DETAIL_FILE"
    exit 1
fi

echo "Found image URI: $IMAGE_URI"

# Extract region and account from the image URI
REGION=$(echo $IMAGE_URI | cut -d'.' -f4)
ACCOUNT_ID=$(echo $IMAGE_URI | cut -d'.' -f1)

echo "Detected region: $REGION"
echo "Detected account: $ACCOUNT_ID"

# Authenticate Docker with ECR
echo "Authenticating Docker with ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Stop any existing containers
echo "Stopping existing containers..."
docker stop graphql-backend || true
docker rm graphql-backend || true
# Also stop demo-backend to free port 3000 (remove these lines if you want both running on different ports)
docker stop demo-backend || true
docker rm demo-backend || true

# Pull and run the new image
echo "Pulling Docker image: $IMAGE_URI"
docker pull $IMAGE_URI

echo "Starting new container..."

# Load environment variables if .env file exists
ENV_FILE="/opt/app/.env"
ENV_ARGS=""
if [ -f "$ENV_FILE" ]; then
    echo "Loading environment variables from $ENV_FILE"
    ENV_ARGS="--env-file $ENV_FILE"
    echo "Environment variables loaded (hiding secrets):"
    cat $ENV_FILE | grep -v PASSWORD || true
else
    echo "Warning: No .env file found at $ENV_FILE"
fi

docker run -d \
    --name graphql-backend \
    -p 3000:3000 \
    --restart unless-stopped \
    $ENV_ARGS \
    $IMAGE_URI

echo "Container started successfully"

# Verify container is running
sleep 5
if docker ps | grep -q graphql-backend; then
    echo "SUCCESS: Container is running"
    docker ps | grep graphql-backend
    exit 0
else
    echo "ERROR: Container failed to start"
    docker ps -a | grep graphql-backend || echo "No graphql-backend container found"
    exit 1
fi