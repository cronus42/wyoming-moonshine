# Home Assistant Moonshine Wyoming ASR

This repository provides a Wyoming protocol server that exposes Moonshine ONNX speech recognition for use with Home Assistant's Wyoming integration.

## Python usage

From a checked-out repo with dependencies installed:

```bash
python -m wyoming_moonshine --uri tcp://0.0.0.0:10300 --model moonshine/tiny --language en
```

This starts a Wyoming server on TCP port 10300.

## Development

### Local setup

1. Create a virtual environment and install runtime dependencies:
   - `make setup` (uses `python3.13 -m venv .venv` and installs `requirements.txt`), or
   - `python3 -m venv .venv` and `pip install -r requirements.txt`.
2. Activate the virtual environment:
   - `source .venv/bin/activate`.
3. Install development dependencies (tests, etc.):
   - `make dev-install`, or
   - `pip install -r requirements-dev.txt`.

### Running tests

With the virtual environment active:

```bash
make test
```

### Contributing

See `CONTRIBUTING.md` for guidelines on opening issues and pull requests.

## Docker image

A minimal image is published to GitHub Container Registry:

- Image: `ghcr.io/cronus42/wyoming-moonshine:latest`

### Build and push (for development)

```bash
# Build locally
docker build -t wyoming-moonshine:latest .

# Tag and push to GHCR (requires ghcr.io auth with write:packages)
IMAGE=ghcr.io/cronus42/wyoming-moonshine:latest
docker tag wyoming-moonshine:latest "$IMAGE"
docker push "$IMAGE"
```

## Running on a remote host with Docker Compose

On the host that will run the ASR server (e.g. `sanctuarymoon.local`), add a service similar to:

```yaml
services:
  wyoming-moonshine:
    image: ghcr.io/cronus42/wyoming-moonshine:latest
    container_name: wyoming-moonshine
    restart: unless-stopped
    command:
      - "--uri"
      - "tcp://0.0.0.0:10300"
      - "--model"
      - "moonshine/tiny"
      - "--language"
      - "en"
    ports:
      - "10300:10300"  # hostPort:containerPort
```

Then:

```bash
docker compose pull wyoming-moonshine
docker compose up -d wyoming-moonshine
```

The Wyoming server will now be reachable at `tcp://<host>:10300` (for example `tcp://sanctuarymoon.local:10300`).

## Home Assistant configuration

1. In Home Assistant, go to **Settings → Devices & services → Add integration**.
2. Add a **Wyoming** integration instance pointing at:
   - Host: the Docker host running this server (e.g. `sanctuarymoon.local`)
   - Port: `10300`
3. Go to **Settings → Voice assistants → Pipelines** and edit your default pipeline.
4. Under **Speech-to-text**, select the Wyoming / Moonshine server as the STT provider.
5. Use Assist (microphone or text) to send requests through the pipeline; the `wyoming-moonshine` container logs will show transcript activity.
