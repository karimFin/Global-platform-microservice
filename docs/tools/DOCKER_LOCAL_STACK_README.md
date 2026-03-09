# Docker Local Stack README

## Why we implemented Docker for local development

Developers need a fast way to run the platform without full cloud setup.
Docker Compose gives a single local runtime for service integration testing..

## How it works here

- Local stack starts from project compose configuration
- Primary command entry is Make:
  - `make dev`
  - `make down`

## Why this is useful

- new developers can run the stack quickly
- integration issues are caught before cluster deployment
- same local workflow across the team

## Basic commands

```bash
make dev
make down
```
