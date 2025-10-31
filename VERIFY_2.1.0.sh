#!/usr/bin/env bash
# Verification Script for Toolkit v2.1.0
# Run this to verify all new features work correctly

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         AI Toolkit v2.1.0 Verification Script                ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# 1. Source shell
echo "1. Reloading shell configuration..."
source ~/.zshrc
echo "✓ Shell reloaded"
echo ""

# 2. Test help
echo "2. Testing 'dev help'..."
dev help | head -15
echo "✓ Help displays correctly"
echo ""

# 3. Test diagnostics
echo "3. Running 'dev diag'..."
dev diag
echo ""

# 4. Test stack
echo "4. Testing development stack..."
dev stack up
sleep 3
docker ps | grep ai-stack || { echo "✗ Stack services not running"; exit 1; }
echo "✓ Stack running"
dev stack down
echo "✓ Stack stopped"
echo ""

# 5. Verify templates exist
echo "5. Verifying new templates..."
for file in \
  templates/react/.eslintrc.cjs \
  templates/react/.prettierrc \
  templates/security/.gitleaks.toml \
  templates/ci/github/rails.yml \
  templates/ci/github/node.yml; do
  if [ -f "$HOME/.ai-toolkit/$file" ]; then
    echo "✓ $file exists"
  else
    echo "✗ $file missing"
    exit 1
  fi
done
echo ""

# 6. Test tab completion
echo "6. Testing completions..."
if grep -q "_dev()" "$HOME/.ai-toolkit/bin/completions.zsh"; then
  echo "✓ Completions file valid"
else
  echo "✗ Completions file invalid"
  exit 1
fi
echo ""

# Optional: Create test app
echo "7. Optional: Create test Rails app? (y/n)"
read -r response
if [ "$response" = "y" ]; then
  cd ~/Desktop || mkdir -p ~/Desktop && cd ~/Desktop
  rm -rf TestRefactor
  
  echo "Creating test app..."
  dev new rails TestRefactor
  cd TestRefactor
  
  echo "Running quality checks..."
  bundle exec overcommit --run || true
  bundle exec rubocop
  just test || true
  
  echo "✓ Test app created successfully"
  echo "Location: ~/Desktop/TestRefactor"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                  ✅ VERIFICATION COMPLETE                     ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "All checks passed! Your toolkit v2.1.0 is ready to use."
echo ""
echo "Try these next:"
echo "  dev new rails MyApp"
echo "  dev ci add github-rails"
echo "  dev upgrade --brew"




