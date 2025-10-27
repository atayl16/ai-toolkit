#!/usr/bin/env bash
# Unit tests for bin/functions.sh

set -e

# Source test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/unit_test_framework.sh"

# Source functions under test
TOOLKIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$TOOLKIT_DIR/bin/functions.sh"

# Cleanup function
cleanup() {
  # Remove any test files created during tests
  rm -f /tmp/test_file
  rm -f /tmp/test_dir_*
}

# Register cleanup
trap cleanup EXIT

# Test suite
test_suite_start "bin/functions.sh"

# Test _ai_success
assert "success function exists" "command -v _ai_success >/dev/null 2>&1"

# Test _ai_info
assert "info function exists" "command -v _ai_info >/dev/null 2>&1"

# Test _ai_err
assert "error function exists" "command -v _ai_err >/dev/null 2>&1"

# Test scan_here function exists
assert "scan_here function exists" "command -v scan_here >/dev/null 2>&1"

# Test new_interview function exists
assert "new_interview function exists" "command -v new_interview >/dev/null 2>&1"

# Test ai_bootstrap_repo function exists
assert "ai_bootstrap_repo function exists" "command -v ai_bootstrap_repo >/dev/null 2>&1"

# Test ai_init_here function exists
assert "ai_init_here function exists" "command -v ai_init_here >/dev/null 2>&1"

# Test ai_new_plan function exists
assert "ai_new_plan function exists" "command -v ai_new_plan >/dev/null 2>&1"

# Test ai_diagnose function exists
assert "ai_diagnose function exists" "command -v ai_diagnose >/dev/null 2>&1"

# Test stack_up function exists
assert "stack_up function exists" "command -v stack_up >/dev/null 2>&1"

# Test stack_down function exists
assert "stack_down function exists" "command -v stack_down >/dev/null 2>&1"

# Summary
test_suite_summary

