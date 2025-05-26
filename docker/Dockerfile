# -----------------------------------------------------------------------------
# docker/Dockerfile – CPU-only Gensyn node image (Ubuntu 22.04)
# -----------------------------------------------------------------------------
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# 1) System dependencies (python, git, curl, gnupg)
RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 python3-venv python3-pip \
      git curl gnupg ca-certificates

# 2) Add Yarn’s official GPG key & repo
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg \
      | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" \
      > /etc/apt/sources.list.d/yarn.list

# 3) Add NodeSource for Node 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

# 4) Install Node.js 20 + Yarn
RUN apt-get update && apt-get install -y --no-install-recommends \
      nodejs yarn

# 5) Clone the rl-swarm repo
RUN git clone --depth 1 https://github.com/gensyn-ai/rl-swarm /opt/rl-swarm
WORKDIR /opt/rl-swarm

# 6) Pre-install Python dependencies into a .venv (including torch)
RUN python3 -m venv .venv && \
    . .venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements-cpu.txt

# 7) Pre-install modal-login (UI) dependencies via Yarn
WORKDIR /opt/rl-swarm/modal-login
RUN yarn install

# 8) Copy entrypoint and make it executable
WORKDIR /opt/rl-swarm
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 38331
ENTRYPOINT ["/entrypoint.sh"]
