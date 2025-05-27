#!/usr/bin/env bash
set -euo pipefail

SERVICE=node2
IDENT_DIR=./identities/$SERVICE
IMAGE=ghcr.io/ashishki/gensyn-node:cpu-2.7.5
P2P_PORT=38332

mkdir -p "$IDENT_DIR"

if [ -f "$IDENT_DIR/swarm.pem" ]; then
  echo "✅ Identity exists → starting via Compose"
  docker compose up -d "$SERVICE"
  exit 0
fi

echo "🔄 No identity found: bootstrapping $SERVICE via 'docker run'…"

# 1) Launch a throwaway container WITHOUT mounting swarm.pem
docker run -d --name bootstrap-$SERVICE \
  -e CPU_ONLY=1 \
  -e P2P_PORT=$P2P_PORT \
  -p $P2P_PORT:$P2P_PORT \
  -v "$(pwd)/data/$SERVICE/modal-login/temp-data":/opt/rl-swarm/modal-login/temp-data \
  $IMAGE \
  bash -c 'source .venv/bin/activate && printf "Y\nA\n0.5\nN\n" | ./run_rl_swarm.sh'

# 2) Wait for the file to appear inside that container
echo "⏳ Waiting for /opt/rl-swarm/swarm.pem in bootstrap-$SERVICE…"
while ! docker exec bootstrap-$SERVICE test -f /opt/rl-swarm/swarm.pem; do
  sleep 2
done

# 3) Stop & copy out the key
echo "⏹ Stopping bootstrap container"
docker stop bootstrap-$SERVICE
echo "📂 Copying swarm.pem out to host"
docker cp bootstrap-$SERVICE:/opt/rl-swarm/swarm.pem "$IDENT_DIR"/swarm.pem

# 4) Clean up the bootstrap container
docker rm bootstrap-$SERVICE

# 5) Now start via Compose (with the real mount in your compose file)
echo "🚀 Restarting $SERVICE properly via Compose"
docker compose up -d "$SERVICE"

echo "✅ $SERVICE is up with persistent identity."
