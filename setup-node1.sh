#!/usr/bin/env bash
set -euo pipefail

# Name of the service and container
SERVICE="node1"
CONTAINER="gensyn-test1"
IDENT_DIR="./identities/$SERVICE"

# Ensure identity directory exists
mkdir -p "$IDENT_DIR"

echo "→ 1) Starting $SERVICE without existing swarm.pem"
docker compose up -d "$SERVICE"

echo "→ 2) Waiting for 'Training  loop starting…' in logs"
docker logs -f "$CONTAINER" | sed -n '/Training  loop starting/ q'

echo "→ 3) Copying generated swarm.pem to host → $IDENT_DIR/swarm.pem"
docker cp "$CONTAINER":/opt/rl-swarm/swarm.pem "$IDENT_DIR"/swarm.pem

echo "→ 4) Stopping $SERVICE"
docker compose stop "$SERVICE"

echo "→ 5) Restarting $SERVICE with mounted swarm.pem"
docker compose up -d "$SERVICE"

echo "→ Setup complete: $SERVICE is now running with persistent identity key."
