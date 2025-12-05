"""Entry point for the Moonshine Wyoming ASR server.

Run with:

    python -m wyoming_moonshine --uri tcp://0.0.0.0:10300 --model moonshine/tiny --language en

This starts a Wyoming server that Home Assistant can use as a local
speech-to-text engine via the Wyoming integration.
"""

from __future__ import annotations

import argparse
import asyncio
import logging

from wyoming.server import serve_forever

from .handler import MoonshineAsrHandler


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Wyoming protocol server for Moonshine ONNX speech recognition.",
    )

    parser.add_argument(
        "--uri",
        default="tcp://0.0.0.0:10300",
        help="Wyoming server URI, e.g. tcp://0.0.0.0:10300",
    )
    parser.add_argument(
        "--model",
        default="moonshine/tiny",
        help=(
            "Moonshine model name, e.g. moonshine/tiny, moonshine/base, "
            "moonshine/tiny-ko, ..."
        ),
    )
    parser.add_argument(
        "--language",
        default="en",
        help="Language code reported to clients (e.g. en, en-US, ko)",
    )
    parser.add_argument(
        "--log-level",
        default="INFO",
        help="Logging level (DEBUG, INFO, WARNING, ERROR)",
    )

    return parser.parse_args()


async def _async_main() -> None:
    args = _parse_args()

    logging.basicConfig(
        level=getattr(logging, args.log_level.upper(), logging.INFO),
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    )

    logger = logging.getLogger(__name__)

    handler = MoonshineAsrHandler(model_name=args.model, language=args.language)

    logger.info(
        "Starting Moonshine Wyoming ASR server on %s with model %s (language=%s)",
        args.uri,
        args.model,
        args.language,
    )

    await serve_forever(args.uri, handler)


def main() -> None:
    asyncio.run(_async_main())


if __name__ == "__main__":  # pragma: no cover
    main()
