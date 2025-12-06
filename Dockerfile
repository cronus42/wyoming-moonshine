FROM python:3.13-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Install system deps (only if really needed) and Python deps in one layer
COPY requirements.txt ./

RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && pip install --upgrade pip \
    && pip install -r requirements.txt \
    && apt-get purge -y git \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*
COPY wyoming_moonshine ./wyoming_moonshine

EXPOSE 10300

ENTRYPOINT ["python", "-m", "wyoming_moonshine"]
CMD ["--uri", "tcp://0.0.0.0:10300", "--model", "moonshine/tiny", "--language", "en"]
