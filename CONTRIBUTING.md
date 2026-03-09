# Contributing

## Welcome

Thanks for your interest in contributing to GPM.

## Contribution flow

1. Fork the repository
2. Create a feature branch from `dev`
3. Make focused changes with clear commit messages
4. Run quality checks locally
5. Open a pull request to `dev`

## Local checks

```bash
make lint
make format-check
```

## Pull request expectations

- describe problem and solution clearly
- include validation notes
- keep changes scoped and reviewable
- update docs when behavior changes

## Labels

- `preview`: triggers preview deployment workflow on PRs to `dev`
- `iac`: infrastructure or platform-as-code changes
- `reliability`: SRE and operational improvements

## Standards

- follow existing repository conventions
- avoid breaking unrelated modules
- prefer declarative infrastructure and reproducible workflows
