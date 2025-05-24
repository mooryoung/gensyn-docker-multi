# -----------------------------------------------------------------------------
# docker/Dockerfile – CPU-only Gensyn node, Ubuntu 22.04
# -----------------------------------------------------------------------------
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# ---- base deps --------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-venv python3-pip git curl gnupg ca-certificates

# ---- Yarn repo + Node 20 LTS ------------------------------------------------
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" \
        > /etc/apt/sources.list.d/yarn.list
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get update && apt-get install -y --no-install-recommends nodejs yarn

# ---- clone rl-swarm into a known path --------------------------------------
RUN git clone --depth 1 https://github.com/gensyn-ai/rl-swarm /opt/rl-swarm

WORKDIR /opt/rl-swarm

# ---- copy entrypoint --------------------------------------------------------
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 38331
ENTRYPOINT ["/entrypoint.sh"]
