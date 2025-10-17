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
ENV PATH="/app:$PATH"
COPY . .

# install python packages
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
RUN uv export | uv pip install --system -r -

# Make identify.py executable
RUN chmod a+x /app/identify.py && \
    echo '#!/usr/bin/env python3' | cat - /app/identify.py > /tmp/identify.py && \
    mv /tmp/identify.py /app/identify.py
