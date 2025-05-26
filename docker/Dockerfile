# ------------------------------------------------------------------------------
#   docker/Dockerfile  –  CPU-only Gensyn node image (Ubuntu 22.04)
# ------------------------------------------------------------------------------

FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# ---------- System deps --------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils           \
    python3 python3-pip python3-venv git curl gnupg ca-certificates

# ---------- Yarn repo  +  Node 20 LTS ------------------------------------------
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" \
        > /etc/apt/sources.list.d/yarn.list
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get update && apt-get install -y --no-install-recommends nodejs yarn

# ---------- Python deps (CPU wheels) ------------------------------------------
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install \
        torch==2.5.1 -f https://download.pytorch.org/whl/torch_stable.html \
        jinja2==3.1.3 \
        # add any other common deps here to keep first start instant
        hf-transfer==0.1

# ---------- Clone rl-swarm source ---------------------------------------------
RUN git clone --depth 1 https://github.com/gensyn-ai/rl-swarm /opt/rl-swarm
WORKDIR /opt/rl-swarm

# ---- Pre-install modal-login dependencies ---------------
WORKDIR /opt/rl-swarm/modal-login          
RUN yarn install --network-timeout 100000  
WORKDIR /opt/rl-swarm                      

# --- overwrite the default CPU config ---------------------------------------------
COPY docker/grpo-qwen-0.5b-cpu.yaml \
     hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml
     
# ---------- Copy entrypoint with auto-answers ---------------------------------
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 38331
ENTRYPOINT ["/entrypoint.sh"]