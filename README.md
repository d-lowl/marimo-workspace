# Marimo Workspace

A Dockerized marimo editor for deployment to Kubernetes clusters with pre-installed dependencies for faster startup.

## Overview

This project provides a containerized marimo editor server that's ready for deployment to Kubernetes. The image includes all necessary dependencies and is configured for GitOps workflows.

## Quick Start

### Local Development

```bash
# Build the image
docker build -t marimo-workspace:latest .

# Run locally for testing
docker run -p 7000:7000 \
  -e MARIMO_TOKEN=test123 \
  marimo-workspace:latest
```

The editor will be available at `http://localhost:7000` with the token `test123`.

### Environment Variables

- `MARIMO_PORT`: Port for the marimo server (default: 7000)
- `MARIMO_TOKEN`: Authentication token for the editor (required)
- `MARIMO_ALLOW_ORIGINS`: CORS allowed origins (default: *)
- `MARIMO_NOTEBOOK_DIR`: Notebook directory within workspace (default: notebooks)
- `MARIMO_BASE_URL`: Base URL for the editor (default: /)
- `GIT_USER_EMAIL`: Git user email for commits
- `GIT_USERNAME`: Git username for commits

## Deployment

### GitHub Container Registry

The image is automatically built and published to GitHub Container Registry via GitHub Actions.

```bash
# Pull the latest image
docker pull ghcr.io/$(git config get-remote.origin.url | sed 's/.*:\(.*\)\/.*/\1/')/marimo-workspace:latest

# Pull a specific version
docker pull ghcr.io/$(git config get-remote.origin.url | sed 's/.*:\(.*\)\/.*/\1/')/marimo-workspace:0.0.1
```

### Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: marimo-workspace
spec:
  replicas: 1
  selector:
    matchLabels:
      app: marimo-workspace
  template:
    metadata:
      labels:
        app: marimo-workspace
    spec:
      containers:
      - name: marimo-workspace
        image: ghcr.io/your-username/marimo-workspace:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 7000
        env:
        - name: MARIMO_TOKEN
          valueFrom:
            secretKeyRef:
              name: marimo-secrets
              key: token
```

## Development

### Building Images

```bash
# Local development build
docker build -t marimo-workspace:dev .

# Versioned build
docker build -t marimo-workspace:0.0.1 .

# Build for GitHub Container Registry
docker build -t ghcr.io/your-username/marimo-workspace:0.0.1 .
```

### Testing

```bash
# Test the container locally
docker run -p 7000:7000 \
  -e MARIMO_TOKEN=test123 \
  marimo-workspace:latest

# Test health check
curl http://localhost:7000/
```

## Architecture

- **Base Image**: `python:3.11-slim`
- **Dependencies**: `marimo[mcp]>=0.17.7`, `openai`, `uv`
- **Port**: 7000
- **Workspace**: `/workspace`
- **Notebook Directory**: `/workspace/notebooks` (configurable)

## CI/CD

GitHub Actions automatically:
1. Builds the Docker image on push to main
2. Tags images with semantic versions
3. Publishes to GitHub Container Registry
4. Creates releases for new versions

## License

See LICENSE file for details.