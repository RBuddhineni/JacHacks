# Railway / container deploy: needs a current Node (Vite 6 + Jac client) and Python.
# ubuntu:22.04 apt "nodejs" is too old (~12.x) and breaks the client bundle / runtime.

FROM python:3.12-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:${PATH}"
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg \
    bash \
    build-essential \
  && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://raw.githubusercontent.com/jaseci-labs/jaseci/main/scripts/install.sh | bash

WORKDIR /app

COPY . .

RUN jac install

EXPOSE 8000

# Railway sets PORT; bind is 0.0.0.0 via jac.toml [serve]. --no-dev avoids dev-only assumptions.
CMD ["sh", "-c", "exec jac start main.jac -p ${PORT:-8000} --no-dev"]
