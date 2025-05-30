<!--
Pull Request Template for Gensyn Docker Multi-Node Toolkit
This template helps maintain consistent, high-quality contributions
-->

## 🎯 What This PR Does

**Brief description:**
<!-- One-line summary in imperative mood, e.g., "Add GPU support for multi-node deployments" -->

**Problem solved:**
<!-- What specific issue does this address? Link issues with #123 -->

**Impact:**
<!-- How does this improve the toolkit for users? -->

---

## 🔧 Changes Made

### Files Modified
- [ ] `prepare-nodes.sh` - Core orchestration logic
- [ ] `docker/` - Container definitions or build scripts  
- [ ] `README.md` - Documentation updates
- [ ] `docker-compose.yml` template - Service configuration
- [ ] Other: _specify files_

### Change Type
- [ ] 🚀 **Feature** - New functionality
- [ ] 🐛 **Bug Fix** - Fixes existing issue
- [ ] 📚 **Documentation** - README, guides, comments
- [ ] 🔧 **Enhancement** - Improves existing functionality  
- [ ] 🏗️ **Infrastructure** - CI/CD, build process
- [ ] 🔐 **Security** - Fixes security vulnerabilities

---

## ✅ Testing Checklist

### Local Testing
- [ ] **Clean Environment**: Tested on fresh Ubuntu 22.04+ system
- [ ] **Script Execution**: `./prepare-nodes.sh N` completes without errors
- [ ] **Container Launch**: `./setup-nodex.sh` succeeds
- [ ] **Multi-node**: Verified with 2+ nodes for resource conflicts
- [ ] **Logs**: No error messages in `docker compose logs`

### Edge Cases  
- [ ] **Zero Nodes**: Handles `./prepare-nodes.sh 0` gracefully
- [ ] **Large Scale**: Tested with 5+ nodes (if applicable)  
- [ ] **Resource Limits**: Verified CPU/memory boundaries
- [ ] **Port Conflicts**: No overlap in P2P port assignments
- [ ] **Permission Issues**: Correct file permissions maintained

### Platform Compatibility
- [ ] **Docker Version**: Works with Docker 20.0+ and Compose v2
- [ ] **System Resources**: Respects CPU/memory constraints
- [ ] **File Paths**: No hardcoded paths breaking on different systems

---

## 📋 Code Quality

### Standards Compliance
- [ ] **Bash Standards**: Scripts use `set -euo pipefail`
- [ ] **Error Handling**: Proper error messages and exit codes
- [ ] **Documentation**: New features documented in README.md
- [ ] **Commit Messages**: Follow conventional commit format (`feat:`, `fix:`, `docs:`)

### Performance  
- [ ] **Resource Efficiency**: No unnecessary resource consumption
- [ ] **Startup Time**: Changes don't slow container initialization
- [ ] **Scaling**: Performance maintained with multiple nodes

---

## 🔗 Related Issues

**Closes**: #<!-- issue number -->
**Related**: #<!-- related issues -->

---

## 📸 Screenshots/Logs

<!-- If UI changes or new features, include before/after screenshots -->
<!-- For script changes, include example output -->

```bash
# Example command output showing the change
$ ./prepare-nodes.sh 3
✓ Creating directory structure...
✓ Generating docker-compose.yml with 3 nodes...
✓ Port allocation: 38331-38333
✓ CPU allocation: 0-19, 20-39, 40-59
```

---

## 🚀 Deployment Notes

### Breaking Changes
- [ ] **None** - Fully backward compatible
- [ ] **Minor** - Requires documentation update only
- [ ] **Major** - Requires user migration (describe below)

<!-- If breaking changes, provide migration steps -->

### Post-Merge Actions
- [ ] Update Docker image tags if container changes
- [ ] Update documentation examples
- [ ] Notify community in discussions/Discord
- [ ] Other: _specify_

---

## 💭 Additional Context

<!-- Any additional information reviewers should know -->
<!-- Technical decisions, alternative approaches considered, etc. -->

---

## 👀 Review Checklist (for maintainers)

- [ ] **Functionality**: Feature works as described
- [ ] **Code Quality**: Follows project conventions  
- [ ] **Testing**: Adequate test coverage
- [ ] **Documentation**: Clear and accurate
- [ ] **Security**: No security vulnerabilities introduced
- [ ] **Performance**: No performance regressions