IMAGE_NAME ?= wyoming-moonshine
IMAGE_TAG ?= latest
CONTAINER_NAME ?= wyoming-moonshine
PORT ?= 10300
PYTHON ?= python3.13

.PHONY: help setup dev-install test build deploy

# Default target
help: ## Show this help message
	@printf "Home Assistant Moonshine Wyoming server\n"
	@printf "Usage: make [target]\n\n"
	@printf "Available targets:\n"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | \
		sed -E 's/^([a-zA-Z0-9_-]+):.*?## (.*)$$/  \1\t\2/'

# Create a local Python virtualenv and install runtime dependencies
setup: ## Create a local Python virtualenv and install runtime dependencies
	$(PYTHON) -m venv .venv
	. .venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt

# Install development dependencies into the virtualenv
dev-install: ## Install development dependencies into the virtualenv
	. .venv/bin/activate && pip install -r requirements-dev.txt

# Run the test suite using pytest in the virtualenv
test: ## Run the test suite with pytest
	. .venv/bin/activate && PYTHONPATH=. pytest

# Build the Docker image for the Moonshine Wyoming ASR server
build: ## Build the Docker image for the Moonshine Wyoming ASR server
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

# Run the Docker container exposing the Wyoming TCP port
# Override IMAGE_NAME, IMAGE_TAG, CONTAINER_NAME, or PORT as needed, e.g.:
#   make deploy IMAGE_NAME=wyoming-moonshine PORT=10300
deploy: ## Run the Docker container exposing the Wyoming TCP port on $(PORT)
	docker run -d --name $(CONTAINER_NAME) -p $(PORT):10300 $(IMAGE_NAME):$(IMAGE_TAG)
