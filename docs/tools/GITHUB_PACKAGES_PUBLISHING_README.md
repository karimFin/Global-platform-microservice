# GitHub Packages Publishing README

## Why this was implemented

The repository had no visible package in GitHub Packages.
To make package publishing simple and repeatable, we added a manual workflow that publishes a container package to GHCR.

## What gets published

- Package type: container image
- Registry: GitHub Container Registry (GHCR)
- Package location: `ghcr.io/<owner>/<image_name>`
- Default build source: `frontend/Dockerfile`

## Workflow added

- `.github/workflows/publish-ghcr-package.yml`

It can be run manually from the Actions tab.

## How to use

1. Open Actions.
2. Run workflow: `Publish GHCR Package`.
3. Set inputs:
   - `image_name` (default `gpm-frontend`)
   - `image_tag` (default `latest`)
4. After success, check:
   - `https://github.com/<owner>/<repo>/packages`

## Why this is useful in this project

- gives a real package entry in GitHub Packages
- supports versioned deploy artifacts for environments
- keeps publishing process in code and auditable
