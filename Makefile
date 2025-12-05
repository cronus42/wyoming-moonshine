IMAGE_NAME ?= wyoming-moonshine
IMAGE_TAG ?= latest
CONTAINER_NAME ?= wyoming-moonshine
PORT ?= 10300
PYTHON ?= python3.13

.PHONY: help setup build deploy

# Default target
help: ## Show this help message
	@echo "Home Assistant Moonshine Wyoming server"
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "  %-10s %s\\n", $$1, $$2}' $(MAKEFILE_LIST)

# Create a local Python virtualenv and install dependencies
setup: ## Create a local Python virtualenv and install dependencies
	$(PYTHON) -m venv .venv
	. .venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt

# Build the Docker image for the Moonshine Wyoming ASR server
build: ## Build the Docker image for the Moonshine Wyoming ASR server
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

# Run the Docker container exposing the Wyoming TCP port
# Override IMAGE_NAME, IMAGE_TAG, CONTAINER_NAME, or PORT as needed, e.g.:
#   make deploy IMAGE_NAME=wyoming-moonshine PORT=10300
deploy: ## Run the Docker container exposing the Wyoming TCP port on $(PORT)
	docker run -d --name $(CONTAINER_NAME) -p $(PORT):10300 $(IMAGE_NAME):$(IMAGE_TAG)
