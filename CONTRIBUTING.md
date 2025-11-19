# Contributing Guide

Thank you for contributing! This project uses automated PR-based releases.

## Quick Start

```bash
# 1. Fork and clone
git clone https://github.com/YOUR_USERNAME/dht-22-ha.git

# 2. Create feature branch
git checkout -b feat/my-feature

# 3. Make changes with conventional commits
git commit -m "feat: add temperature alerts"

# 4. Push and create PR
git push origin feat/my-feature
```

## PR Title Format

Your PR title determines the version bump:

| PR Title | Version Change | Use Case |
|----------|----------------|----------|
| `[MAJOR] description` | 1.0.0 → 2.0.0 | Breaking changes |
| `[MINOR] description` | 1.0.0 → 1.1.0 | New features |
| `[PATCH] description` | 1.0.0 → 1.0.1 | Bug fixes |
| `[SKIP] description` | No release | Docs/chore only |

**Or use conventional commits:**
- `feat: description` → MINOR
- `fix: description` → PATCH
- `docs: description` → SKIP

## Commit Message Format

Use **Conventional Commits** for automatic changelog generation:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style (formatting, etc)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Tests
- `chore`: Maintenance

### Examples

```bash
feat: add support for DHT11 sensors
fix: correct negative temperature reading
docs: update wiring diagram
feat!: change MQTT topic structure  # Breaking change
```

## What Happens When PR Merges?

1. **PR title validated** automatically
2. **Labels auto-applied** based on type
3. **On merge:**
   - ✅ Changelog generated from commits
   - ✅ Version bumped in all files
   - ✅ Git tag created
   - ✅ Code compiled to bytecode
   - ✅ GitHub release published
   - ✅ Comment added to PR with release link

## Testing Checklist

Before submitting PR:

- [ ] Tested on Raspberry Pi Pico W
- [ ] Verified MQTT connectivity
- [ ] Checked Home Assistant integration
- [ ] Tested negative temperatures (if temp-related)
- [ ] Reviewed logs for errors
- [ ] Code follows PEP 8
- [ ] Commits follow conventional format
- [ ] Documentation updated

## Code Style

- Follow PEP 8 for Python
- Use descriptive variable names
- Add comments for complex logic
- Keep functions focused and small

## PR Review Process

Your PR will be merged if:
- ✅ Code follows style guidelines
- ✅ Commits follow conventional format
- ✅ Changes are tested
- ✅ Documentation is updated
- ✅ PR title is valid format
- ✅ Code owner approves (@DiarmuidKelly)

## Version Bumping Rules

- **PATCH** (0.0.X): Bug fixes, docs, minor tweaks
- **MINOR** (0.X.0): New features, backward-compatible
- **MAJOR** (X.0.0): Breaking changes, incompatible API

**Note:** You don't need to manually update version numbers. When your PR is merged, the CI/CD workflow automatically updates the `VERSION` file and `__version__` in the code based on your PR title.

## Questions?

- Check [README.md](README.md) for project overview
- See [.github/BRANCH_PROTECTION.md](.github/BRANCH_PROTECTION.md) for ruleset details
- Open an [issue](https://github.com/DiarmuidKelly/dht-22-ha/issues) for questions

Thank you for contributing! 🎉
