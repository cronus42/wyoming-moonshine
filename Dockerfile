# Minimal Docker image for Moonshine Wyoming ASR server

FROM python:3.13-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Install Python dependencies
RUN apt-get update && apt-get install -y git
COPY requirements.txt ./
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy application code
COPY wyoming_moonshine ./wyoming_moonshine

EXPOSE 10300

# Default entrypoint/command can be overridden at `docker run` time
ENTRYPOINT ["python", "-m", "wyoming_moonshine"]
CMD ["--uri", "tcp://0.0.0.0:10300", "--model", "moonshine/tiny", "--language", "en"]
