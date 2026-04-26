CODEX_NPM_PACKAGE ?= @openai/codex
CODEX_VERSION ?= $(shell npm view $(CODEX_NPM_PACKAGE) version)
PNPM_VERSION ?= 10.33.2
IMAGE_NAME ?= codex-slim
IMAGE_TAG := $(IMAGE_NAME):$(CODEX_VERSION)
DOCKER_BUILD_NETWORK ?= host
DOCKER_RUN_NETWORK ?= none

.PHONY: version build smoke size

version:
	@npm view $(CODEX_NPM_PACKAGE) version

build:
	@test -n "$(CODEX_VERSION)" || (echo "CODEX_VERSION is required" >&2; exit 1)
	docker build \
		--network=$(DOCKER_BUILD_NETWORK) \
		--build-arg CODEX_NPM_PACKAGE=$(CODEX_NPM_PACKAGE) \
		--build-arg CODEX_VERSION=$(CODEX_VERSION) \
		--build-arg PNPM_VERSION=$(PNPM_VERSION) \
		-t $(IMAGE_TAG) \
		.
	@echo "Built $(IMAGE_TAG)"

smoke:
	@test -n "$(CODEX_VERSION)" || (echo "CODEX_VERSION is required" >&2; exit 1)
	docker run --network=$(DOCKER_RUN_NETWORK) --rm $(IMAGE_TAG) codex --version
	docker run --network=$(DOCKER_RUN_NETWORK) --rm $(IMAGE_TAG) node --version
	docker run --network=$(DOCKER_RUN_NETWORK) --rm $(IMAGE_TAG) pnpm --version
	docker run --network=$(DOCKER_RUN_NETWORK) --rm $(IMAGE_TAG) python --version
	docker run --network=$(DOCKER_RUN_NETWORK) --rm $(IMAGE_TAG) python -c "import PIL, websockets; print(PIL.__version__)"
	docker run --network=$(DOCKER_RUN_NETWORK) --rm $(IMAGE_TAG) bwrap --version
	docker run --network=$(DOCKER_RUN_NETWORK) --rm $(IMAGE_TAG) rg --version
	docker run --network=$(DOCKER_RUN_NETWORK) --rm $(IMAGE_TAG) magick -version
	docker run --network=$(DOCKER_RUN_NETWORK) --rm $(IMAGE_TAG) sh -lc 'rm -rf /tmp/schema && codex app-server generate-json-schema --out /tmp/schema && test -f /tmp/schema/codex_app_server_protocol.schemas.json'
	docker run --network=$(DOCKER_RUN_NETWORK) --rm $(IMAGE_TAG) sh -lc 'codex app-server --listen ws://127.0.0.1:31337 >/tmp/app-server.log 2>&1 & pid=$$!; trap "kill $$pid 2>/dev/null || true" EXIT; for i in $$(seq 1 50); do curl -fsS http://127.0.0.1:31337/readyz >/dev/null 2>/dev/null && exit 0; sleep 0.2; done; cat /tmp/app-server.log >&2; exit 1'

size:
	docker image ls $(IMAGE_NAME) --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}'
