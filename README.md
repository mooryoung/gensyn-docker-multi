#  Gensyn Multi-Node CPU Deployment

**Stable Docker Guide for running multiple Gensyn nodes on a single server**

[![Docker](https://img.shields.io/badge/Docker-20%2B-blue?logo=docker)](https://www.docker.com/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%2B-orange?logo=ubuntu)](https://ubuntu.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 Overview

This guide is designed for experienced users who have already run Gensyn Node manually and have their API keys (`userApiKey.json`, `userData.json`) and optionally `swarm.pem` files ready. You'll learn how to deploy multiple nodes on a single server using Docker Compose with maximum automation and fault tolerance.

> **⚠️ First-time setup?**  
> Complete the [primary setup guide](https://teletype.in/@sng_dao/gensyn2) first to generate and save all your keys, then return here.

## 🛠️ Server Requirements

### System Requirements
- **OS**: Ubuntu 22.04+
- **Docker**: 20.0+
- **Docker Compose**: 2.x
- **Permissions**: sudo access
- **Ports**: SSH (22), P2P ports (38331, 38332, etc.)

### Required Packages
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y git curl wget software-properties-common apt-transport-https ca-certificates gnupg lsb-release
```

## 🐳 Docker Installation

### Install Docker Engine
```bash
# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker compose version
```

### Essential Docker Commands
```bash
# Container Management
docker compose up -d                    # Start all containers in background
docker compose up -d node1              # Start specific node
docker compose down                     # Stop all containers
docker compose restart node1            # Restart specific node
docker compose stop node1               # Stop specific node
docker compose start node1              # Start specific node

# Monitoring & Logs
docker compose logs -f                  # View all logs (follow mode)
docker compose logs -f node1            # View specific node logs
docker compose logs --tail=100 node1    # View last 100 lines
docker compose ps                       # Show running containers
docker compose top                      # Show running processes

# Updates & Maintenance
docker compose pull                     # Pull latest images
docker compose build --no-cache         # Rebuild images
docker system prune -a                 # Clean up unused resources
docker images                          # List images
docker ps -a                          # List all containers
```

## 📁 Project Structure

After cloning and running the preparation script, your project will have this structure:

```
gensyn-docker-multi/
├── data/                               # Auto-created by prepare-nodes.sh
│   ├── node1/modal-login/temp-data/    # Your JSON keys for node1
│   ├── node2/modal-login/temp-data/    # Your JSON keys for node2
│   └── nodeX/modal-login/temp-data/    # Your JSON keys for nodeX
├── identities/                         # Auto-created by prepare-nodes.sh
│   ├── node1/                          # swarm.pem storage for node1
│   ├── node2/                          # swarm.pem storage for node2
│   └── nodeX/                          # swarm.pem storage for nodeX
├── docker/
│   ├── Dockerfile
│   ├── entrypoint.sh
│   └── grpo-qwen-0.5b-cpu.yaml
│── prepare-nodes.sh               # Main preparation script
├── run_rl_swarm_json_save.sh
├── docker-compose.yml                  # Auto-generated
└── README.md
```

## 🔑 Preparing Keys

> **⚠️ IMPORTANT**  
> Obtain your `userApiKey.json` and `userData.json` keys following the [primary setup guide](https://teletype.in/@sng_dao/gensyn2).

### Copy Keys for Each Node
After running `prepare-nodes.sh`, directories are already created. Just copy your keys:

```bash
# Copy your keys for each node (directories already exist)
cp /path/to/your/userApiKey.json data/node1/modal-login/temp-data/
cp /path/to/your/userData.json data/node1/modal-login/temp-data/

cp /path/to/your/userApiKey.json data/node2/modal-login/temp-data/
cp /path/to/your/userData.json data/node2/modal-login/temp-data/

# Repeat for all nodes...

# Set correct permissions
chmod 600 data/node*/modal-login/temp-data/*.json
```

> **📝 Note**: The `swarm.pem` files will be auto-generated during bootstrap - no need to copy them manually!

## 🐳 Docker Image

The Docker image is already built and published. Simply pull it:

```bash
# Pull the ready-to-use image
docker pull ghcr.io/ashishki/gensyn-node:cpu-2.7.5

# Verify image
docker images | grep gensyn-node
```

> **📝 Note**: The image tag `ghcr.io/ashishki/gensyn-node:cpu-2.7.5` is pre-configured in the generated `docker-compose.yml`

### Building from Source (Optional)
If you want to build the image yourself or make modifications:

```bash
# Build CPU image from source
docker build -t ghcr.io/ashishki/gensyn-node:cpu-2.7.5 -f docker/Dockerfile .
```

## 🚀 Quick Start Guide

### Step 1: Prepare Infrastructure
```bash
# Clone repository
git clone https://github.com/ashishki/gensyn-docker-multi.git
cd gensyn-docker-multi

# Prepare nodes (example: 3 nodes)
chmod +x prepare-nodes.sh
./prepare-nodes.sh 3
```

### Step 2: Pull Docker Image
```bash
# Pull the ready-to-use image
docker pull ghcr.io/ashishki/gensyn-node:cpu-2.7.5
```

### Step 3: Add Your Keys
```bash
# Copy your JSON keys to each node
cp /path/to/your/userApiKey.json data/node1/modal-login/temp-data/
cp /path/to/your/userData.json data/node1/modal-login/temp-data/
cp /path/to/your/userApiKey.json data/node2/modal-login/temp-data/
cp /path/to/your/userData.json data/node2/modal-login/temp-data/
# ... repeat for all nodes

# Set permissions
chmod 600 data/node*/modal-login/temp-data/*.json
```

### Step 4: Bootstrap & Deploy
```bash
# Bootstrap nodes (generates swarm.pem for each)
chmod +x scripts/setup-node*.sh
./scripts/setup-node1.sh
./scripts/setup-node2.sh
./scripts/setup-node3.sh

# Start all nodes
docker compose up -d
```

### Step 5: Monitor
```bash
# Check status
docker compose ps

# View logs
docker compose logs -f
```

## ⚙️ Docker Compose Configuration

The `docker-compose.yml` file is automatically generated by `prepare-nodes.sh` with optimal settings:

### Example Generated Configuration (3 nodes)
```yaml
version: "3.9"
services:
  node1:
    image: ghcr.io/ashishki/gensyn-node:cpu-2.7.5
    container_name: gensyn-test1
    environment:
      - P2P_PORT=38331
      - CPU_ONLY=1
    volumes:
      - "./data/node1/modal-login/temp-data:/opt/rl-swarm/modal-login/temp-data"
      - "./identities/node1/swarm.pem:/opt/rl-swarm/swarm.pem"
      - "./run_rl_swarm_json_save.sh:/opt/rl-swarm/run_rl_swarm.sh:ro"
    ports:
      - "38331:38331"
    restart: on-failure
    cpuset: "0-19"           # CPU cores 0-19 (20 cores)
    deploy:
      resources:
        limits:
          cpus: "20.0"
    dns:
      - 8.8.8.8
      - 1.1.1.1

  node2:
    image: ghcr.io/ashishki/gensyn-node:cpu-2.7.5
    container_name: gensyn-test2
    environment:
      - P2P_PORT=38332
      - CPU_ONLY=1
    volumes:
      - "./data/node2/modal-login/temp-data:/opt/rl-swarm/modal-login/temp-data"
      - "./identities/node2/swarm.pem:/opt/rl-swarm/swarm.pem"
      - "./run_rl_swarm_json_save.sh:/opt/rl-swarm/run_rl_swarm.sh:ro"
    ports:
      - "38332:38332"
    restart: on-failure
    cpuset: "20-39"          # CPU cores 20-39 (20 cores)
    deploy:
      resources:
        limits:
          cpus: "20.0"
    dns:
      - 8.8.8.8
      - 1.1.1.1

  node3:
    image: ghcr.io/ashishki/gensyn-node:cpu-2.7.5
    container_name: gensyn-test3
    environment:
      - P2P_PORT=38333
      - CPU_ONLY=1
    volumes:
      - "./data/node3/modal-login/temp-data:/opt/rl-swarm/modal-login/temp-data"
      - "./identities/node3/swarm.pem:/opt/rl-swarm/swarm.pem"
      - "./run_rl_swarm_json_save.sh:/opt/rl-swarm/run_rl_swarm.sh:ro"
    ports:
      - "38333:38333"
    restart: on-failure
    cpuset: "40-59"          # CPU cores 40-59 (20 cores)
    deploy:
      resources:
        limits:
          cpus: "20.0"
    dns:
      - 8.8.8.8
      - 1.1.1.1
```

### Key Features of Generated Config:
- **Auto-allocated ports**: 38331, 38332, 38333, etc.
- **CPU affinity**: 20 cores per node with no overlap
- **Resource limits**: Enforced CPU limits for fair resource sharing
- **Proper restart policy**: `on-failure` for stability
- **Optimized DNS**: Google and Cloudflare DNS servers

## 🔧 Network Configuration

### Required Ports
- **SSH**: 22 (for server access)
- **P2P Ports**: 38331, 38332, 38333, etc. (one per node)

### Firewall Setup (UFW)
```bash
# Enable UFW
sudo ufw enable

# Allow SSH
sudo ufw allow 22

# Allow P2P ports for your nodes
sudo ufw allow 38331
sudo ufw allow 38332
sudo ufw allow 38333
# Add more as needed

# Check status
sudo ufw status
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Directory Error
```
IsADirectoryError: [Errno 21] Is a directory: '/opt/rl-swarm/swarm.pem'
```
**Solution**: Ensure `swarm.pem` is a file, not a directory
```bash
ls -la identities/node1/swarm.pem
# Should show a file, not a directory
```

#### 2. Bootstrap Connection Failed
```
failed to connect to bootstrap peers
```
**Solution**: Check network connectivity and firewall settings
```bash
# Test connectivity
ping 8.8.8.8
# Check if ports are open
netstat -tlnp | grep 38331
```

#### 3. JSON Keys Not Found
**Solution**: Verify file permissions and paths
```bash
ls -la data/node1/modal-login/temp-data/
chmod 600 data/node1/modal-login/temp-data/*.json
```

### Useful Debugging Commands
```bash
# Check container health
docker compose ps

# View detailed logs
docker compose logs -f node1

# Enter container shell
docker compose exec node1 /bin/bash

# Check resource usage
docker stats

# Inspect container configuration
docker inspect gensyn-node1
```

## 🔄 Updates and Maintenance

### Updating Images
```bash
# Pull latest images
docker compose pull

# Restart specific node
docker compose up -d node1

# Or restart all nodes
docker compose up -d
```

### Backup Important Files
```bash
# Create backup directory
mkdir -p backups/$(date +%Y%m%d)

# Backup keys and identities
cp -r data/ backups/$(date +%Y%m%d)/
cp -r identities/ backups/$(date +%Y%m%d)/
```

## 📊 Monitoring

### Health Checks
```bash
# Check all containers
docker compose ps

# Monitor resource usage
docker stats --no-stream

# View logs for all nodes
docker compose logs --tail=50
```

### Log Management
```bash
# Rotate logs to prevent disk space issues
docker system prune -f

# View specific timeframe
docker compose logs --since="2h" node1
docker compose logs --until="2023-12-01T12:00:00" node1
```

## ❓ FAQ

### Q: How many ports do I need to open?
**A**: Each node requires one unique P2P port (38331, 38332, etc.) plus SSH port 22.

### Q: Can I automate the deployment of all nodes?
**A**: Yes! The `prepare-nodes.sh` script automates infrastructure preparation. Each node still requires manual bootstrap for `swarm.pem` generation, but the setup is now streamlined.

### Q: How do I add more nodes?
**A**: 
1. Create new directories in `data/` and `identities/`
2. Copy your keys
3. Add new service to `docker-compose.yml`
4. Run the setup script

### Q: How do I monitor node performance?
**A**: Use `docker stats`, `docker compose logs`, and monitor the application-specific metrics through the node's output.

## 🎯 Best Practices

- **Security**: Never store secrets in public repositories
- **Backups**: Regularly backup `swarm.pem` and JSON keys
- **Updates**: Monitor the original [gensyn-ai/rl-swarm](https://github.com/gensyn-ai/rl-swarm) repository for updates
- **Resources**: Monitor CPU and memory usage to optimize node allocation
- **Logs**: Implement log rotation to prevent disk space issues

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

- **Primary Setup Guide**: [https://teletype.in/@sng_dao/gensyn2](https://teletype.in/@sng_dao/gensyn2)
- **Original Repository**: [gensyn-ai/rl-swarm](https://github.com/gensyn-ai/rl-swarm)
- **Issues**: [GitHub Issues](https://github.com/ashishki/gensyn-docker-multi/issues)

---

🎉 **You're all set!** If everything is configured correctly, your nodes will start up and maintain stable operation with persistent identity and quick recovery capabilities.