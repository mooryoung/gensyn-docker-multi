#!/usr/bin/env bash
set -euo pipefail

# Usage: ./prepare-nodes.sh 3
# Will prepare data/ and identities/ for node1..node3
# and generate a docker-compose.yml with ports 38331–38333
# and cpuset ranges 0–19,20–39,40–59

if [ $# -ne 1 ]; then
  echo "Usage: $0 <number_of_nodes>"
  exit 1
fi

N=$1
BASE_PORT=38331
CORES_PER_NODE=20

# 1) Clean out old compose (if you like) then start a fresh one
cat > docker-compose.yml <<EOF
version: "3.9"
services:
EOF

for ((i=1; i<=N; i++)); do
  PORT=$(( BASE_PORT + i - 1 ))
  CPU_START=$(( (i-1)*CORES_PER_NODE ))
  CPU_END=$(( CPU_START + CORES_PER_NODE - 1 ))
  SVC=node$i

  # A) Prepare host directories
  mkdir -p data/$SVC/modal-login/temp-data
  mkdir -p identities/$SVC

  # B) Append the service block
  cat >> docker-compose.yml <<EOB
  $SVC:
    image: ghcr.io/ashishki/gensyn-node:cpu-2.7.5
    container_name: gensyn-test$i

    environment:
      - P2P_PORT=$PORT
      - CPU_ONLY=1

    volumes:
      - "./data/$SVC/modal-login/temp-data:/opt/rl-swarm/modal-login/temp-data"
      - "./identities/$SVC/swarm.pem:/opt/rl-swarm/swarm.pem"
      - "./run_rl_swarm_json_save.sh:/opt/rl-swarm/run_rl_swarm.sh:ro"

    ports:
      - "$PORT:$PORT"

    restart: on-failure
    cpuset: "$CPU_START-$CPU_END"
    deploy:
      resources:
        limits:
          cpus: "$CORES_PER_NODE.0"

    dns:
       - 8.8.8.8
       - 1.1.1.1

EOB
done

echo "✅ Generated docker-compose.yml for $N nodes."
echo "✅ Created data/ and identities/ subdirs for node1..node$N."
echo
echo "Next steps:"
echo " 1) Copy or generate your JSON login keys into each:"
echo "      data/nodeX/modal-login/temp-data/{userApiKey.json,userData.json}"
echo " 2) Run your bootstrap scripts (setup-nodeX.sh) to generate swarm.pem for each."
echo " 3) Finally: docker compose up -d"
