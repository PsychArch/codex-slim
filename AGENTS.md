# Project Notes

- Keep `README.md` user-facing: purpose, build, run, defaults, and checks only.
- Keep release and registry mechanics out of `README.md`.
- Do not add proxy options or proxy documentation to project files.
- Versioned image tags must exactly match the installed `@openai/codex` npm version.
- Also publish `latest` as an alias for the most recent successful published Codex version.
- Keep Codex config in the container user's natural home path: `/home/node/.codex/config.toml`.
- Keep the Docker Hub overview synced from the user-facing `README.md` with a short Docker Hub description.

# Release

The `docker` GitHub Actions workflow publishes multi-arch images to GHCR and Docker Hub.

Required repository secrets:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

Local validation:

```sh
make build CODEX_VERSION=0.125.0
make smoke CODEX_VERSION=0.125.0
```

Publish from a version tag:

```sh
git tag v0.125.0
git push origin v0.125.0
```

The published image tags are `latest` and the Codex version without the leading `v`, for example `0.125.0`.
