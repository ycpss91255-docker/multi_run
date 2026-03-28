#!/usr/bin/env bash
# Fake setup.sh for testing
base_path="${2:-$(dirname "$0")/..}"
cat > "${base_path}/.env" << ENVEOF
DOCKER_HUB_USER=test
IMAGE_NAME=mock_setup
USER_NAME=testuser
ENVEOF
