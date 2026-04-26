FROM node:24-trixie-slim

ARG CODEX_NPM_PACKAGE=@openai/codex
ARG CODEX_VERSION


RUN apt-get update && apt-get install -y --no-install-recommends \
  bash \
  bubblewrap \
  ca-certificates \
  curl \
  git \
  imagemagick \
  jq \
  openssh-client \
  procps \
  python-is-python3 \
  python3 \
  python3-pil \
  python3-pip \
  python3-venv \
  python3-websockets \
  ripgrep \
  zsh \
  && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  curl --retry 5 --retry-all-errors -LsSf https://astral.sh/uv/install.sh -o /tmp/uv-installer.sh; \
  env UV_UNMANAGED_INSTALL=/usr/local/bin sh /tmp/uv-installer.sh; \
  rm -f /tmp/uv-installer.sh; \
  uv --version

ARG PNPM_VERSION=10.33.2

RUN set -eux; \
  npm install -g "pnpm@${PNPM_VERSION}" "${CODEX_NPM_PACKAGE}@${CODEX_VERSION}"; \
  npm cache clean --force; \
  if ! command -v magick >/dev/null 2>&1; then \
    printf '#!/bin/sh\nexec convert "$@"\n' > /usr/local/bin/magick; \
    chmod +x /usr/local/bin/magick; \
  fi

RUN set -eux; \
  mkdir -p /workspace /home/node/.codex; \
  printf '%s\n' \
    'js_repl_node_path = "/usr/local/bin/node"' \
    'js_repl_node_module_dirs = ["/usr/local/lib/node_modules", "/workspace/node_modules", "/workspace"]' \
    > /home/node/.codex/config.toml; \
  chown -R node:node /workspace /home/node/.codex

USER node
WORKDIR /workspace

RUN set -eux; \
  curl --version; \
  node --version; \
  npm --version; \
  pnpm --version; \
  python --version; \
  python -m pip --version; \
  python -c "import PIL, websockets; print(PIL.__version__)"; \
  uv --version; \
  rg --version; \
  magick -version; \
  codex --version; \
  rm -rf /home/node/.codex/tmp


CMD ["codex", "app-server", "--listen", "stdio://"]
