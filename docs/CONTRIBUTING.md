# Contributing to Gensyn Docker Multi-Node Toolkit

Thank you for your interest in contributing! This project has grown from personal infrastructure automation into a valuable community resource for the Gensyn ecosystem. Every contribution helps make multi-node deployment more accessible to the community.

## 🌟 Why Contribute?

This toolkit addresses real pain points in Gensyn node deployment:
- **Removes complexity** - No more manual YAML editing or port calculations
- **Proven in production** - Battle-tested on bare metal, and cloud
- **Active community need** - Frequently requested by new Gensyn operators
- **Clean architecture** - Well-structured code that's easy to enhance

## 🚀 Quick Start for Contributors

### Prerequisites
- Ubuntu 22.04+ (or equivalent Linux)
- Docker 20.0+ with Compose v2
- Git and basic shell scripting knowledge
- **Optional**: Gensyn API keys for full testing

### Setup Development Environment

```bash
# 1. Fork the repository on GitHub
# 2. Clone your fork
git clone https://github.com/ashishki/gensyn-docker-multi.git
cd gensyn-docker-multi

# 3. Add upstream remote
git remote add upstream https://github.com/ashishki/gensyn-docker-multi.git

# 4. Create a feature branch
git checkout -b feature/your-improvement-name

# 5. Test current functionality
chmod +x prepare-nodes.sh run_rl_swarm_json_save.sh
./prepare-nodes.sh 2  # Quick test with 2 nodes
docker compose up -d  # Verify containers start
docker compose down -v  # Cleanup
```

## 📋 Types of Contributions

### 🐛 Bug Fixes
**High Impact**: Fix deployment issues, resource conflicts, or script errors
- **Examples**: Port conflicts, CPU allocation bugs, permission issues
- **Testing**: Verify fix on clean Ubuntu system
- **Documentation**: Update troubleshooting section if needed

### 🚀 Features
**Medium/High Impact**: Add functionality that benefits multiple users
- **Examples**: GPU support, resource profiles, monitoring integration
- **Design**: Open an issue first to discuss approach
- **Testing**: Include comprehensive test cases

### 📚 Documentation
**High Impact**: Improve user onboarding and experience
- **Examples**: Better examples, troubleshooting guides, FAQ sections
- **Testing**: Follow your own instructions on a fresh system
- **Clarity**: Write for users new to Docker or Gensyn

### 🔧 Infrastructure
**Medium Impact**: Improve development workflow
- **Examples**: CI/CD, automated testing, build optimization
- **Scope**: Keep changes focused and well-documented

## 🛠️ Development Standards

### Shell Scripting
```bash
#!/bin/bash
set -euo pipefail  # Always include this

# Use meaningful variable names
NODE_COUNT=${1:-1}
BASE_PORT=38331

# Proper error handling
if [[ $NODE_COUNT -lt 1 ]]; then
    echo "❌ Error: Node count must be >= 1"
    exit 1
fi

# Clear user feedback
echo "✓ Creating $NODE_COUNT nodes..."
```

### Docker Best Practices
- Use specific image tags, not `latest`
- Include health checks where appropriate
- Optimize layer caching in Dockerfiles
- Follow multi-stage build patterns

### Documentation Style
- Use clear, imperative language ("Deploy nodes" not "Deploying nodes")
- Include working code examples
- Test all commands on fresh systems
- Use emoji sparingly but effectively (✓ ❌ 🚀)

## 🧪 Testing Guidelines

### Local Testing Requirements
Every PR must include evidence of testing:

```bash
# 1. Clean slate test
docker system prune -af
rm -rf data/ identities/ docker-compose.yml

# 2. Feature test
./prepare-nodes.sh 3  # Or your test case
./setup-nodex.sh
docker compose ps  # Should show healthy containers
docker compose logs --tail=20  # Check for errors

# 3. Cleanup test  
docker compose down nodex
ls -la  # Should only show original files
```

### Platform Testing
**Minimum**: Ubuntu 22.04 with Docker 20.0+
**Preferred**: Also test on:
- Different Ubuntu/Debian versions
- CentOS/RHEL (if shell compatible)
- Docker Desktop (macOS/Windows if possible)

### Performance Testing
For changes affecting resource allocation:
```bash
# Monitor resource usage
docker stats --no-stream
# Verify CPU affinity
docker exec gensyn-test1 taskset -p 1
# Check port allocation
netstat -tlnp | grep 38331
```

## 📝 Code Review Process

### Preparing Your PR
1. **Self-review**: Read your changes from a fresh perspective
2. **Clean history**: Squash fixup commits, use meaningful commit messages
3. **Documentation**: Update README.md for user-facing changes
4. **Testing**: Include test results in PR description

### Commit Message Format
```
type(scope): brief description

Examples:
feat(scripts): add GPU support for multi-node deployments
fix(compose): correct port allocation for nodes >10  
docs(readme): improve quick start instructions
refactor(prepare): simplify CPU allocation logic
```

### PR Review Checklist
When reviewing others' PRs:
- ✅ **Functionality**: Does it work as described?
-