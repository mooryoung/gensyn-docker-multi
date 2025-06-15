# -----------------------------------------------------------------------------
# docker/Dockerfile – CPU-only Gensyn node image (Ubuntu 22.04)
# -----------------------------------------------------------------------------
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# 1) System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 python3-venv python3-pip \
      git curl gnupg ca-certificates \
      nano

# 2) Add Yarn’s GPG key & repo
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

# 3) Add Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get update && apt-get install -y --no-install-recommends nodejs yarn

# 4) Clone rl-swarm at specific commit
RUN git clone https://github.com/gensyn-ai/rl-swarm /opt/rl-swarm && \
    cd /opt/rl-swarm && \
    git checkout 385e0b3

WORKDIR /opt/rl-swarm

# 5) Override config
COPY docker/grpo-qwen-0.5b-cpu.yaml \
     /opt/rl-swarm/hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml

# 6) Create virtual env and install dependencies
RUN python3 -m venv .venv && \
    . .venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements-cpu.txt && \

    # 6a) Patch grpo_runner.py
    sed -i 's|dht = hivemind.DHT(start=True, startup_timeout=30, \*\*self._dht_kwargs(grpo_args))|dht = hivemind.DHT(start=True, ensure_bootstrap_success=False, startup_timeout=120, **self._dht_kwargs(grpo_args))|' hivemind_exp/runner/grpo_runner.py && \

    # 6b) Patch p2p_daemon.py inside site-packages
    sed -i 's|idle_timeout: float = 30|idle_timeout: float = 120|' .venv/lib/python3.10/site-packages/hivemind/p2p/p2p_daemon.py && \
    sed -i 's|startup_timeout: float = 15|startup_timeout: float = 120|' .venv/lib/python3.10/site-packages/hivemind/p2p/p2p_daemon.py

# 7) Install modal-login UI dependencies
WORKDIR /opt/rl-swarm/modal-login
RUN yarn install

# 8) Copy entrypoint
WORKDIR /opt/rl-swarm
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 38331
ENTRYPOINT ["/entrypoint.sh"]
