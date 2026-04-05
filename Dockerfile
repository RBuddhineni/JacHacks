FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:${PATH}"

# System deps: curl + Node.js (needed by jac install for npm packages)
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Jac (full ecosystem: jaclang + byllm + jac-client + jac-scale)
RUN curl -fsSL https://raw.githubusercontent.com/jaseci-labs/jaseci/main/scripts/install.sh | bash

WORKDIR /app
COPY . .

# Install project npm dependencies declared in jac.toml
RUN jac install

EXPOSE 8000

# Railway sets $PORT automatically; fall back to 8000 locally
CMD ["sh", "-c", "jac start main.jac -p ${PORT:-8000}"]
