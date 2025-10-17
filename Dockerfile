FROM python:3.12-trixie

# Set environment variables to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# install system programs
RUN apt-get update && apt-get install --no-install-recommends -y \
    golang \
    ffmpeg \
    imagemagick \
    ghostscript \
    libreoffice-nogui \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

# install python packages
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
RUN uv export | uv pip install --system -r -

# Make identify.py executable and create wrapper script in /usr/local/bin
RUN chmod a+x /app/identify.py && \
    echo '#!/bin/sh' > /usr/local/bin/identify.py && \
    echo 'exec python3 /app/identify.py "$@"' >> /usr/local/bin/identify.py && \
    chmod a+x /usr/local/bin/identify.py
