#!/usr/bin/env bash
set -euo pipefail

SERVICE=node2
CONTAINER=gensyn-test2
IDENT=./identities/$SERVICE

mkdir -p "$IDENT"

if [ -f "$IDENT/swarm.pem" ]; then
  echo "Identity for $SERVICE exists → starting"
  docker compose up -d "$SERVICE"
  exit 0
fi

echo "Bootstrapping $SERVICE identity…"
docker compose up -d "$SERVICE"
docker logs -f "$CONTAINER" | sed -n '/Training  loop starting/ q'

# if it was a dir by mistake, remove it
[ -d "$IDENT/swarm.pem" ] && rm -rf "$IDENT/swarm.pem"

echo "Copying swarm.pem → $IDENT/swarm.pem"
docker cp "$CONTAINER":/opt/rl-swarm/swarm.pem "$IDENT/swarm.pem"

echo "Restarting $SERVICE with persistent key"
docker compose stop "$SERVICE"
docker compose up -d "$SERVICE"
