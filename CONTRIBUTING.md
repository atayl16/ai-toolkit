# Contributing to AI Development Toolkit

Thank you for your interest in improving the toolkit! This guide will help you test changes and maintain quality.

## Development Workflow

### Making Changes

1. **Edit templates** in `templates/` directories
2. **Update commands** in `bin/dev` and `bin/functions.sh`
3. **Update completions** in `bin/completions.zsh`
4. **Update documentation** (README.md, CHANGELOG.md, etc.)

### Testing Your Changes

#### 1. Run Diagnostics
```bash
dev diag
```
This checks:
- Tool versions (ruby, rails, node, docker, git)
- rbenv configuration
- Required gems and CLIs
- Template file existence

#### 2. Test Core Commands
```bash
# Test help
dev help

# Test stack management
dev stack up
sleep 2
dev stack down

# Test diagnostics
dev diag
```

#### 3. Test App Creation
```bash
cd ~/Desktop/test || mkdir -p ~/Desktop/test && cd ~/Desktop/test
rm -rf TestRefactor

# Create test app
dev new rails TestRefactor
cd TestRefactor

# Run quality checks
bundle exec overcommit --run
bundle exec rubocop
just test
```

#### 4. Test Rails+React
```bash
cd ~/Desktop/test
rm -rf TestReact

dev new rails-react TestReact
cd TestReact

# Verify backend
just test

# Verify frontend
cd client
npm run lint
npm test
cd ..
```

#### 5. Test Sandbox
```bash
dev sandbox https://github.com/rails/rails --private
# Should create temp directory and run scans
```

#### 7. Test CI Templates
```bash
cd TestRefactor
dev ci add github-rails
ls .github/workflows/
cat .github/workflows/ci.yml
```

### Full Test Script

```bash
#!/usr/bin/env bash
set -e

echo "=== Full Toolkit Test ==="

# 1. Diagnostics
echo "1. Running diagnostics..."
dev diag || { echo "Diagnostics failed"; exit 1; }

# 2. Stack
echo "2. Testing stack..."
dev stack up
sleep 3
docker ps | grep ai-stack
dev stack down

# 3. Rails app
echo "3. Creating Rails app..."
cd ~/Desktop/test 2>/dev/null || mkdir -p ~/Desktop/test && cd ~/Desktop/test
rm -rf TestApp
dev new rails TestApp
cd TestApp
bundle exec rubocop -a
just test

# 4. CI addition
echo "4. Adding CI..."
dev ci add github-rails
[ -f .github/workflows/ci.yml ] || { echo "CI file missing"; exit 1; }

# 5. Cleanup
cd ..
rm -rf TestApp

echo "=== All tests passed! ==="
```

## Code Style

### Shell Scripts
- Use `set -euo pipefail` for safety
- Use `local` for variables in functions
- Add comments for complex logic
- Use `info()`, `err()`, `success()` for output

### Templates
- Add header comments explaining purpose
- Use consistent formatting (2-space indent for YAML)
- Include inline documentation

### Documentation
- Update README.md for new features
- Add CHANGELOG.md entry with version bump
- Update help text in `bin/dev`
- Add examples where helpful

## Versioning

Follow semantic versioning:
- **Major** (3.0.0): Breaking changes
- **Minor** (2.1.0): New features, backward compatible
- **Patch** (2.0.1): Bug fixes

## Commit Messages

Format: `type: description`

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Maintenance tasks

Examples:
```
feat: add dev diag command for toolkit diagnostics
fix: handle Docker not running in dev sandbox
docs: update README with JobWizard instructions
refactor: extract React templates to templates/react/
```

## Pull Request Process

1. Create feature branch
2. Make changes
3. Run full test script
4. Update documentation
5. Update CHANGELOG.md
6. Submit PR with clear description

## Questions?

Open an issue or check the docs:
- README.md - Full documentation
- QUICKSTART.md - Getting started
- WORKFLOWS.md - Common patterns

## License

MIT - Use freely, contribute openly!




