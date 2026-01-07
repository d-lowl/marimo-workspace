# AGENTS.md

This file provides guidelines and commands for agentic coding assistants working on the marimo-workspace repository.

## Project Overview

Marimo Workspace is a containerized marimo editor server designed for Kubernetes deployment. The project provides a pre-configured Docker image with marimo, OpenAI, and uv dependencies for fast startup in production environments.

**Key Components:**
- Dockerfile: Multi-stage container build based on `python:3.11-slim`
- entrypoint.sh: Git configuration and marimo server startup script
- GitHub Actions: Automated CI/CD pipeline for image building and publishing
- Target: Production-ready container for GitOps workflows

## Build Commands

### Docker Operations
```bash
# Build local development image
docker build -t marimo-workspace:latest .

# Build with specific version
docker build -t marimo-workspace:0.0.1 .

# Test container locally
docker run -p 7000:7000 -e MARIMO_TOKEN=test123 marimo-workspace:latest

# Build for GitHub Container Registry
docker build -t ghcr.io/your-username/marimo-workspace:0.0.1 .

# Test container health
curl http://localhost:7000/
```

### GitHub Actions
```bash
# CI/CD workflow triggers on:
# - Push to main (builds and publishes)
# - Pull requests (build only)
# - Release publishing (creates tagged releases)
```

## Code Style Guidelines

### Shell Script (entrypoint.sh)
- **Shebang**: Use `#!/bin/bash`
- **Error Handling**: Start with `set -euo pipefail`
- **Quoting**: Always quote variables: `"${VAR:-default}"`
- **Environment Variables**: Use parameter expansion with defaults: `"${VAR:-default}"`
- **Functions**: Use snake_case for function names
- **Comments**: Brief comments explaining complex logic
- **Indentation**: 2 spaces (consistent with existing code)

### Dockerfile
- **Base Image**: `python:3.11-slim` (keep current for size/security balance)
- **Environment**: Set `DEBIAN_FRONTEND=noninteractive`
- **Layer Optimization**: Group related commands in single RUN instruction
- **Cleanup**: Always clean apt caches: `rm -rf /var/lib/apt/lists/*`
- **Security**: Use `--no-install-recommends` for apt packages
- **Permissions**: Set execute permissions: `chmod +x /entrypoint.sh`
- **Multi-stage**: Single-stage is sufficient for this simple use case

### YAML (.github/workflows)
- **Naming**: kebab-case for workflow filenames
- **Jobs**: Use descriptive job names (e.g., `build-and-push`)
- **Actions**: Use latest stable versions (v4+ for major actions)
- **Security**: Never log secrets, use GitHub's secret handling
- **Caching**: Enable GHA caching for Docker layers
- **Permissions**: Minimum required permissions only

### File Organization
```
marimo-workspace/
├── Dockerfile              # Container build definition
├── entrypoint.sh           # Container startup script
├── README.md              # Project documentation
├── LICENSE                # License file
└── .github/
    └── workflows/
        └── docker-build.yml # CI/CD pipeline
```

## Dependencies

### Python Packages
- **marimo[mcp]>=0.17.7**: Core editor with MCP support
- **openai**: OpenAI API integration
- **uv**: Fast Python package manager

### System Packages
- **git**: Version control within workspace
- **ca-certificates**: SSL certificate verification

## Environment Variables

### Required
- `MARIMO_TOKEN`: Authentication token (must be provided)

### Optional
- `MARIMO_PORT`: Server port (default: 7000)
- `MARIMO_ALLOW_ORIGINS`: CORS origins (default: *)
- `MARIMO_NOTEBOOK_DIR`: Notebook directory (default: notebooks)
- `GIT_USER_EMAIL`: Git user email
- `GIT_USERNAME`: Git username

## Security Guidelines

- **Never commit secrets** to the repository
- **Use GitHub Secrets** for sensitive configuration
- **Run as non-root** (consider for future enhancement)
- **Minimal dependencies** to reduce attack surface
- **Regular base image updates** for security patches

## Testing Strategy

### Local Testing
1. Build Docker image locally
2. Run container with test environment
3. Verify marimo server starts correctly
4. Test basic editor functionality
5. Verify health check endpoint

### CI Testing
- GitHub Actions builds on every PR
- Container builds validated automatically
- Integration tests can be added as needed

## Git Workflow

### Commit Messages
**All commits must be prefixed with**: `[AI $MODEL_NAME]`

Examples:
- `[AI GPT-4] Fix Dockerfile pip install syntax`
- `[AI Claude] Add GitHub Actions workflow`
- `[AI Sonnet] Update README with deployment instructions`

### Branch Strategy
- `main`: Production-ready code
- Feature branches: Use descriptive names
- All changes via pull requests when adding complexity

## Container Image Guidelines

### Naming
- **Image Name**: `marimo-workspace`
- **Registry**: GitHub Container Registry (ghcr.io)
- **Tagging**: Semantic versioning (0.0.1, 0.1.0, 1.0.0)

### Version Management
- Start at 0.0.1 for initial release
- Auto-increment minor versions for new features
- Patch versions for bug fixes
- Major versions for breaking changes

## Performance Considerations

- **Layer Caching**: Optimize Dockerfile layer order
- **Image Size**: Use slim base images, minimal dependencies
- **Startup Time**: Pre-install dependencies for fast container start
- **Resource Limits**: Consider memory/CPU limits for Kubernetes

## Deployment Integration

### Kubernetes
- **Port**: Expose 7000
- **Health Check**: HTTP GET to root path
- **Volumes**: Mount persistent storage for notebooks
- **Secrets**: Use Kubernetes secrets for MARIMO_TOKEN

### GitOps
- **Argo CD Compatible**: Declarative manifests
- **Image Updates**: Automated via GitHub Actions
- **Rollback**: Version tags support rollbacks