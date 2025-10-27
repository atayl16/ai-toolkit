#!/usr/bin/env bash
# AI Toolkit Smoke Tests
# Verify all modes build working apps

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              AI Toolkit Smoke Test Suite                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

TEST_DIR="$HOME/Desktop/toolkit-tests"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Function to cleanup on exit
cleanup() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Cleanup: Removing test apps..."
  cd "$TEST_DIR"
  rm -rf TestRails TestReact TestJobWizard
  echo "✓ Cleanup complete"
}

# Register cleanup function
trap cleanup EXIT

# Cleanup old tests
rm -rf TestRails TestReact TestJobWizard

# Function to test app startup
test_app_startup() {
  local app_dir="$1"
  local app_name="$2"
  
  echo "Testing $app_name..."
  cd "$app_dir"
  
  # Test: App starts without errors
  echo "  → Running bundle install..."
  bundle install > /dev/null 2>&1 || { echo "  ✗ bundle install failed"; return 1; }
  
  echo "  → Testing Rails environment..."
  bundle exec rails runner "puts 'Rails OK'" > /dev/null 2>&1 || { echo "  ✗ Rails environment failed"; return 1; }
  
  echo "  → Running migrations..."
  bundle exec rails db:migrate > /dev/null 2>&1 || { echo "  ✗ Migration failed"; return 1; }
  
  echo "  → Auto-fixing RuboCop issues..."
  bundle exec rubocop -A > /dev/null 2>&1 || true
  
  echo "  ✓ $app_name works"
  cd "$TEST_DIR"
}

# Test 1: Rails app
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 1: Rails App (TIER 1)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
dev new rails TestRails
test_app_startup "TestRails" "Rails App"
echo ""

# Test 2: Rails + React app
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 2: Rails + React App"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
dev new rails-react TestReact
test_app_startup "TestReact" "Rails + React App"
echo ""

# Test 3: JobWizard app
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 3: JobWizard App"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
dev new jobwizard TestJobWizard
test_app_startup "TestJobWizard" "JobWizard App"
echo ""

# Summary
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                  ✅ ALL TESTS PASSED                         ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Test apps cleaned up automatically."
echo ""
echo "To keep test apps, comment out the cleanup trap in the script."

