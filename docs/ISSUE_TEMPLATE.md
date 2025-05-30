<!--
Issue Template for Gensyn Docker Multi-Node Toolkit
Choose the appropriate section below and remove others
-->

## 🐛 Bug Report

<!-- Use this section for bugs, errors, or unexpected behavior -->

### Problem Description
**Brief summary**: 
<!-- Clear, one-sentence description of the issue -->

**Expected behavior**: 
<!-- What you thought would happen -->

**Actual behavior**: 
<!-- What actually happened -->

### Environment Details
| Component | Version/Info |
|-----------|--------------|
| **OS** | `uname -a` output |
| **Docker** | `docker --version` |
| **Compose** | `docker compose version` |
| **Toolkit** | `git rev-parse --short HEAD` |
| **Hardware** | CPU cores, RAM, GPU (if applicable) |

### Reproduction Steps
```bash
# Exact commands that trigger the issue
1. git clone https://github.com/ashishki/gensyn-docker-multi.git
2. cd gensyn-docker-multi  
3. ./prepare-nodes.sh 3
4. # ... specific steps
```

### Error Output
```
# Paste full error messages, stack traces, or logs
# Use docker compose logs -f for container issues
# Use bash -x ./prepare-nodes.sh for script debugging
```

### Additional Context
<!-- Screenshots, configuration files, or other relevant details -->

---

## 🚀 Feature Request

<!-- Use this section for new features or enhancements -->

### Feature Description
**What feature would you like to see?**
<!-- Clear description of the desired functionality -->

**Why is this needed?**
<!-- What problem does this solve? What use case does it enable? -->

### Proposed Solution
**How should it work?**
<!-- Describe the expected behavior, API, or user interface -->

**Example usage:**
```bash
# Show how users would interact with the new feature
./prepare-nodes.sh 5 --gpu --memory=32GB
```

### Alternatives Considered
<!-- Other approaches you've thought about -->

### Implementation Notes
<!-- Any technical details, constraints, or suggestions -->

---

## 📚 Documentation Issue

<!-- Use this section for documentation problems -->

### Documentation Problem
- [ ] **Missing information** - Something important is not documented
- [ ] **Incorrect information** - Documentation doesn't match reality  
- [ ] **Unclear instructions** - Hard to understand or follow
- [ ] **Outdated content** - Documentation is stale

### Specific Location
**File/Section**: 
<!-- e.g., README.md "Quick Start" section -->

**Current content** (if applicable):
<!-- Quote the problematic text -->

**Suggested improvement**:
<!-- What should it say instead? -->

---

## ❓ Help Wanted / Question

<!-- Use this section for usage questions or requests for help -->

### What I'm Trying to Do
<!-- Describe your goal or use case -->

### What I've Tried
```bash
# Commands you've run
# Configuration you've attempted
```

### Specific Question
<!-- What exactly are you stuck on? -->

### Context
- **Experience level**: Beginner / Intermediate / Advanced
- **Deployment target**: Local testing / Production / Cloud platform
- **Scale**: Number of nodes you're trying to deploy

---

## 🔧 Environment Issues

<!-- Use this section for platform-specific problems -->

### Platform Details
- **OS**: Ubuntu 22.04 / CentOS 8 / macOS / Windows WSL2
- **Architecture**: x86_64 / ARM64  
- **Virtualization**: Bare metal / VMware / Cloud (AWS/GCP/Azure)
- **Container Runtime**: Docker Desktop / Docker Engine / Podman

### Resource Constraints
- **CPU Cores**: Available cores for allocation
- **Memory**: Total RAM available  
- **Storage**: Available disk space
- **Network**: Firewall rules, port restrictions

### Error Context
<!-- How does your environment differ from standard setup? -->

---

## 📊 Performance Issue

<!-- Use this section for performance problems -->

### Performance Problem
- [ ] **Slow startup** - Containers take too long to initialize
- [ ] **High resource usage** - CPU/memory consumption too high
- [ ] **Network issues** - Slow P2P connectivity
- [ ] **Scaling problems** - Performance degrades with more nodes

### Measurements
```
# Include metrics like:
# - docker stats output  
# - startup times
# - resource usage graphs
# - network throughput
```

### System Specifications
<!-- Detailed hardware specs for performance context -->

---

## 🔄 Integration Request

<!-- Use this section for integration with other tools/platforms -->

### Integration Target
<!-- What tool/platform should this integrate with? -->
- [ ] **Kubernetes** - Helm charts, operators
- [ ] **Monitoring** - Prometheus, Grafana, DataDog  
- [ ] **CI/CD** - GitHub Actions, Jenkins, GitLab
- [ ] **Cloud Platforms** - AWS Batch, GCP, Azure
- [ ] **Other**: _specify_

### Use Case
<!-- Why is this integration valuable? -->

### Requirements
<!-- Technical requirements or constraints -->

---

## 🏷️ Issue Labels

<!-- Help us categorize by selecting relevant labels -->

**Priority**:
- [ ] 🔥 **Critical** - Blocks deployment completely
- [ ] ⚠️ **High** - Significant impact on users
- [ ] 📋 **Medium** - Important but not urgent  
- [ ] 💡 **Low** - Nice to have

**Complexity**:
- [ ] 🟢 **Good First Issue** - Simple fix for beginners
- [ ] 🟡 **Medium** - Requires some expertise
- [ ] 🔴 **Complex** - Significant development effort

**Area**:
- [ ] 🐳 **Docker** - Container/compose issues
- [ ] 🔧 **Scripts** - Shell script problems  
- [ ] 📚 **Documentation** - README/guide issues
- [ ] 🏗️ **Infrastructure** - CI/CD, builds
- [ ] 🔐 **Security** - Security-related concerns

---

**Thank you for contributing to the project! 🙏**

*Issues are typically triaged within 48 hours. For urgent problems, mention `@ashishki` or reach out on Discord.*