#!/bin/bash
set -e

echo "Stopping existing container if running..."
docker stop graphql-backend || true
docker rm graphql-backend || true

echo "Done."