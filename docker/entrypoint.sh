#!/usr/bin/env bash
# docker/entrypoint.sh
#
# 1. Obtain the P2P port from the P2P_PORT env var (default 38331).
# 2. Create/activate a Python virtual environment.
# 3. Launch Gensyn's run_rl_swarm.sh script.
#
# NOTE: JSON login keys must already be present in
#       /rl-swarm/modal-login/temp-data/ before first start.

set -e

# --------------- PATCH: increase startup_timeout for hivemind ----------------
# This ensures the DHT daemon has more time to start (fixes some network errors)

#./setup-node1.sh
# Configure multiaddr so Hivemind binds to 0.0.0.0 on the desired port.
export HOST_MULTI_ADDRS="/ip4/0.0.0.0/tcp/${P2P_PORT:-38331}"

# Create virtualenv on first run
if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi
source .venv/bin/activate




# Launch RL-Swarm launcher (now upstream script is mounted at this path)
# exec bash ./run_rl_swarm.sh
printf "\n\n\n\n" | ./run_rl_swarm.sh 