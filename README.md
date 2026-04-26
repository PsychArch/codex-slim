# codex-slim

A small Docker image for running Codex CLI and `codex app-server` in Node/Python workspaces.

It includes Codex, Node, pnpm, Python, Pillow/PIL, `websockets`, `uv`, ripgrep, ImageMagick, and common shell tools. Image tags match the installed `@openai/codex` npm version.

## Build

```sh
make build
```

Build a specific Codex version:

```sh
make build CODEX_VERSION=0.125.0
```

## Run

Default app-server over stdio:

```sh
docker run --rm -i codex-slim:<version>
```

Run Codex CLI in the current directory:

```sh
docker run --rm -it -v "$PWD:/workspace" -w /workspace codex-slim:<version> codex --version
```

Run a host-loopback WebSocket app-server:

```sh
docker run --rm -p 127.0.0.1:31337:31337 codex-slim:<version> \
  codex app-server --listen ws://0.0.0.0:31337
```

If you expose WebSocket beyond loopback, enable capability-token auth and mount a token file:

```sh
docker run --rm -p 31337:31337 -v /absolute/token:/run/codex-ws-token:ro codex-slim:<version> \
  codex app-server --listen ws://0.0.0.0:31337 \
  --ws-auth capability-token \
  --ws-token-file /run/codex-ws-token
```

## Defaults

- Base: `node:24-trixie-slim`
- User: non-root `node`
- Workdir: `/workspace`
- Config: `/home/node/.codex/config.toml`
- Command: `codex app-server --listen stdio://`

## Check

```sh
make smoke CODEX_VERSION=<version>
```
