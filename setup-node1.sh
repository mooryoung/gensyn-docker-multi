#!/usr/bin/env bash
set -euo pipefail

SERVICE=node1
CONTAINER=bootstrap-$SERVICE
IDENT_DIR=./identities/$SERVICE
IMAGE=ghcr.io/ashishki/gensyn-node:cpu-2.7.5
P2P_PORT=38331

mkdir -p "$IDENT_DIR"

if [ -f "$IDENT_DIR/swarm.pem" ]; then
  echo "✅ Identity exists → starting via Compose"
  docker compose up -d "$SERVICE"
  exit 0
fi

echo "🔄 No identity found: bootstrapping $SERVICE via 'docker run'…"

# 1) Launch throwaway container WITHOUT mounting swarm.pem
docker run -d --name "$CONTAINER" \
  -e CPU_ONLY=1 \
  -e P2P_PORT=$P2P_PORT \
  -p $P2P_PORT:$P2P_PORT \
  -v "$(pwd)/data/$SERVICE/modal-login/temp-data":/opt/rl-swarm/modal-login/temp-data \
  $IMAGE \
  bash -c 'source .venv/bin/activate && printf "Y\nA\n0.5\nN\n" | ./run_rl_swarm.sh'

# 2) Wait until the key file appears inside that container
echo "⏳ Waiting for /opt/rl-swarm/swarm.pem in $CONTAINER…"
while ! docker exec "$CONTAINER" test -f /opt/rl-swarm/swarm.pem; do
  sleep 2
done
echo "✅ Detected swarm.pem inside container"

# 3) Stop the bootstrap container
echo "⏹ Stopping $CONTAINER"
docker stop "$CONTAINER"

# 4) Remove any stale file or directory on host, then copy out
echo "📂 Copying swarm.pem out to host ($IDENT_DIR/swarm.pem)"
rm -rf "$IDENT_DIR/swarm.pem"
docker cp "$CONTAINER":/opt/rl-swarm/swarm.pem "$IDENT_DIR/swarm.pem"

# 5) Tighten permissions
chmod 600 "$IDENT_DIR/swarm.pem"

# 6) Remove the bootstrap container
docker rm "$CONTAINER"

# 7) Now start the real service via Compose (with the key mounted)
echo "🚀 Restarting $SERVICE properly via Compose"
docker compose up -d "$SERVICE"

echo "✅ $SERVICE is up with its persistent identity key."
