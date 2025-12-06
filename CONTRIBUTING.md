# Contributing

This document describes how to set up a development environment and what is expected for changes and pull requests.

## Supported Python versions

The project is currently developed and tested with:

- Python 3.13

Other recent 3.x versions may work, but 3.13 is the primary target for development and CI.

## Local development setup

1. Clone the repository and change into the project directory.
2. Create a virtual environment and install runtime dependencies:
   - Recommended: `make setup` (creates `.venv` and installs `requirements.txt`).
3. Activate the virtual environment:
   - `source .venv/bin/activate`
4. Install development dependencies (tests and tooling):
   - `make dev-install`, or
   - `pip install -r requirements-dev.txt`

## Running the server locally

With the virtual environment active and dependencies installed:

```bash
python -m wyoming_moonshine --uri tcp://0.0.0.0:10300 --model moonshine/tiny --language en
```

This starts a Wyoming server on TCP port `10300`.

## Running tests

With the virtual environment active:

```bash
make test
```

All tests should pass before you open a pull request.

## Pull request guidelines

- Keep changes focused and incremental.
- Add or update tests when you change behavior.
- Ensure `pytest` passes locally before opening or updating a PR.
- Keep documentation up to date if you change configuration, flags, or usage.

## Releases

Releases are driven by git tags. Pushing a tag like `v0.1.0` triggers the
`docker-publish` GitHub Actions workflow, which builds and publishes Docker
images to GHCR.

To cut a release from an up-to-date `master` branch:

```bash
make release VERSION=v0.1.0
```

This will:
- Verify there are no uncommitted changes
- Pull the latest `master`
- Run the test suite
- Create an annotated tag `v0.1.0`
- Push the tag to `origin` so GitHub Actions can build/publish images
