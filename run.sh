#!/usr/bin/env sh
set -e

# Standalone container entrypoint.
# Mirrors the add-on behavior:
# - optional HF_TOKEN
# - optional warmup download at startup
# - optional offline mode after warmup

# Defaults
WYOMING_URI_DEFAULT="tcp://0.0.0.0:10300"
MOONSHINE_MODEL_DEFAULT="moonshine/tiny"
MOONSHINE_LANGUAGE_DEFAULT="en"
MOONSHINE_LOG_LEVEL_DEFAULT="INFO"
HF_HOME_DEFAULT="/data/hf"
OFFLINE_AFTER_STARTUP_DEFAULT="true"

WYOMING_URI="${WYOMING_URI:-${WYOMING_URI_DEFAULT}}"
MOONSHINE_MODEL="${MOONSHINE_MODEL:-${MOONSHINE_MODEL_DEFAULT}}"
MOONSHINE_LANGUAGE="${MOONSHINE_LANGUAGE:-${MOONSHINE_LANGUAGE_DEFAULT}}"
MOONSHINE_LOG_LEVEL="${MOONSHINE_LOG_LEVEL:-${MOONSHINE_LOG_LEVEL_DEFAULT}}"
HF_HOME="${HF_HOME:-${HF_HOME_DEFAULT}}"
OFFLINE_AFTER_STARTUP="${OFFLINE_AFTER_STARTUP:-${OFFLINE_AFTER_STARTUP_DEFAULT}}"

# If CLI args are provided, prefer them over env defaults.
# This keeps compatibility with `docker run ... -- --uri ... --model ...`.
if [ "$#" -gt 0 ]; then
  # Minimal flag parsing (only for values we need during warmup).
  prev=""
  for arg in "$@"; do
    case "${prev}" in
      --uri)
        WYOMING_URI="${arg}"
        ;;
      --model)
        MOONSHINE_MODEL="${arg}"
        ;;
      --language)
        MOONSHINE_LANGUAGE="${arg}"
        ;;
      --log-level)
        MOONSHINE_LOG_LEVEL="${arg}"
        ;;
      *)
        ;;
    esac
    prev="${arg}"
  done
fi

export HF_HOME
mkdir -p "${HF_HOME}"

# HF_TOKEN is passed through if set; otherwise ensure it isn't exported.
if [ -n "${HF_TOKEN:-}" ]; then
  export HF_TOKEN
else
  unset HF_TOKEN
fi

export MODEL="${MOONSHINE_MODEL}"

echo "Starting wyoming_moonshine with uri=${WYOMING_URI}, model=${MOONSHINE_MODEL}, language=${MOONSHINE_LANGUAGE}, log_level=${MOONSHINE_LOG_LEVEL}, offline_after_startup=${OFFLINE_AFTER_STARTUP}, hf_home=${HF_HOME}"

if [ "${OFFLINE_AFTER_STARTUP}" = "true" ]; then
  echo "Warming model cache (network allowed during startup only)"

  # Ensure we are not in offline mode during warmup.
  unset HF_HUB_OFFLINE
  unset TRANSFORMERS_OFFLINE

  if command -v timeout >/dev/null 2>&1; then
    timeout 300 python - <<'PY'
import os
import tempfile
import wave
from pathlib import Path

import moonshine_onnx

model = os.environ["MODEL"]

# Create a tiny 16kHz/16-bit mono WAV of silence.
fd, wav_path_str = tempfile.mkstemp(suffix=".wav")
os.close(fd)

wav_path = Path(wav_path_str)
with wave.open(str(wav_path), "wb") as wav_file:
    wav_file.setnchannels(1)
    wav_file.setsampwidth(2)
    wav_file.setframerate(16000)
    wav_file.writeframes(b"\x00\x00" * 16000)  # 1 second

try:
    moonshine_onnx.transcribe(wav_path, model)
finally:
    try:
        wav_path.unlink()
    except FileNotFoundError:
        pass
PY
  else
    echo "WARNING: timeout(1) not found; warmup may hang if network is broken"
    python - <<'PY'
import os
import tempfile
import wave
from pathlib import Path

import moonshine_onnx

model = os.environ["MODEL"]

# Create a tiny 16kHz/16-bit mono WAV of silence.
fd, wav_path_str = tempfile.mkstemp(suffix=".wav")
os.close(fd)

wav_path = Path(wav_path_str)
with wave.open(str(wav_path), "wb") as wav_file:
    wav_file.setnchannels(1)
    wav_file.setsampwidth(2)
    wav_file.setframerate(16000)
    wav_file.writeframes(b"\x00\x00" * 16000)  # 1 second

try:
    moonshine_onnx.transcribe(wav_path, model)
finally:
    try:
        wav_path.unlink()
    except FileNotFoundError:
        pass
PY
  fi

  echo "Enabling Hugging Face offline mode for the running server"
  export HF_HUB_OFFLINE=1
  export TRANSFORMERS_OFFLINE=1
fi

# If the user provided args, run with them; otherwise use our defaults.
if [ "$#" -gt 0 ]; then
  exec python -m wyoming_moonshine "$@"
fi

exec python -m wyoming_moonshine \
  --uri "${WYOMING_URI}" \
  --model "${MOONSHINE_MODEL}" \
  --language "${MOONSHINE_LANGUAGE}" \
  --log-level "${MOONSHINE_LOG_LEVEL}"
