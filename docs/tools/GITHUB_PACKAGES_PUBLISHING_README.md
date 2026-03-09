# GitHub Packages Publishing README

## Why this was implemented

The repository had no visible package in GitHub Packages.
To make package publishing simple and repeatable, we added both manual and automatic tag-triggered publishing to GHCR.

## What gets published

- Package type: container image
- Registry: GitHub Container Registry (GHCR)
- Package location: `ghcr.io/<owner>/<image_name>`
- Default build source: `frontend/Dockerfile`

## Workflow added

- `.github/workflows/publish-ghcr-package.yml`

It supports:
- manual run from Actions tab
- automatic publish on git tag push matching `v*`

## How to use

1. Open Actions.
2. Run workflow: `Publish GHCR Package`.
3. Set inputs:
   - `image_name` (default `gpm-frontend`)
   - `image_tag` (default `latest`)
4. After success, check:
   - `https://github.com/<owner>/<repo>/packages`

## Automatic publish from version tags

Push a version tag:

```bash
git tag v0.1.0
git push origin v0.1.0
```

Automatic behavior:
- workflow runs on tag push
- image tag becomes the git tag (`v0.1.0`)
- package defaults to `ghcr.io/<owner>/gpm-frontend`

## Why this is useful in this project

- gives a real package entry in GitHub Packages
- supports versioned deploy artifacts for environments
- keeps publishing process in code and auditable
