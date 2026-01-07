#!/bin/bash
set -euo pipefail

# Configure git
git config --global --add safe.directory "/workspace"
if [ -n "${GIT_USER_EMAIL:-}" ]; then
    git config --global user.email "${GIT_USER_EMAIL}"
fi
if [ -n "${GIT_USERNAME:-}" ]; then
    git config --global user.name "${GIT_USERNAME}"
fi

# Set up working directory
WORKDIR="/workspace/${MARIMO_NOTEBOOK_DIR:-notebooks}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Start marimo
exec marimo edit \
    --host 0.0.0.0 \
    --port "${MARIMO_PORT}" \
    --headless \
    --token-password "${MARIMO_TOKEN}" \
    --allow-origins "${MARIMO_ALLOW_ORIGINS:-*}"