# docker/Dockerfile
#
# Universal CPU-only Gensyn node image.
# Ubuntu 22.04 base + Python, Yarn (official repo), Node 20 LTS.

FROM ubuntu:22.04

# Prevent interactive APT prompts
ENV DEBIAN_FRONTEND=noninteractive

# -------------------------------------------------------------------------
# 1. Core tools required by rl-swarm
# -------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3            \
    python3-venv       \
    python3-pip        \
    git                \
    curl               \
    gnupg              \
    ca-certificates

# -------------------------------------------------------------------------
# 2. Add Yarn’s official APT repository and key
# -------------------------------------------------------------------------
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" \
        > /etc/apt/sources.list.d/yarn.list

# -------------------------------------------------------------------------
# 3. Add NodeSource repo for Node 20 LTS
# -------------------------------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

# -------------------------------------------------------------------------
# 4. Install Node 20 LTS + Yarn from the repos we just added
# -------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs     \
    yarn       \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------------------------
# 5. Clone rl-swarm
# -------------------------------------------------------------------------
WORKDIR /rl-swarm
RUN git clone https://github.com/gensyn-ai/rl-swarm .

# -------------------------------------------------------------------------
# 6. Copy local entrypoint
# -------------------------------------------------------------------------
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Hivemind P2P port (overridden by compose env var)
EXPOSE 38331

ENTRYPOINT ["/entrypoint.sh"]
