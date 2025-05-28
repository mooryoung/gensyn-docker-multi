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
sed -i 's/startup_timeout: float = 15/startup_timeout: float = 120/' .venv/lib/python3.10/site-packages/hivemind/p2p/p2p_daemon.py || true
sed -i 's/startup_timeout=30/startup_timeout=120/g' /opt/rl-swarm/hivemind_exp/runner/*.py || true
#
./setup-node1.sh
# Configure multiaddr so Hivemind binds to 0.0.0.0 on the desired port.
export HOST_MULTI_ADDRS="/ip4/0.0.0.0/tcp/${P2P_PORT:-38331}"

# Create virtualenv on first run
if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi
source .venv/bin/activate




# ----- auto-reply to interactive setup -----
printf "Y\nA\n0.5\nN\n" | ./run_rl_swarm.sh 