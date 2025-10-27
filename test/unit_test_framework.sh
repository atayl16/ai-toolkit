#!/usr/bin/env bash
# Simple Bash Unit Testing Framework
# Minimal, no dependencies, works everywhere

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test output
TEST_OUTPUT=""

# Start test suite
test_suite_start() {
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Running: $1"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Assert function
assert() {
  local name="$1"
  local condition="$2"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  
  if eval "$condition"; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $name"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $name"
    TEST_OUTPUT="${TEST_OUTPUT}\n  Failed: $name"
  fi
}

# Assert equals
assert_eq() {
  local name="$1"
  local actual="$2"
  local expected="$3"
  
  assert "$name" "[ \"$actual\" = \"$expected\" ]"
  
  if [ "$actual" != "$expected" ]; then
    TEST_OUTPUT="${TEST_OUTPUT}\n    Expected: $expected"
    TEST_OUTPUT="${TEST_OUTPUT}\n    Actual: $actual"
  fi
}

# Assert file exists
assert_file_exists() {
  local name="$1"
  local file="$2"
  
  assert "$name" "[ -f \"$file\" ]"
}

# Assert directory exists
assert_dir_exists() {
  local name="$1"
  local dir="$2"
  
  assert "$name" "[ -d \"$dir\" ]"
}

# Print summary
test_suite_summary() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Tests run: $TESTS_RUN"
  echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
  echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
  
  if [ "$TESTS_FAILED" -gt 0 ]; then
    echo -e "\n${RED}Test Failures:${NC}"
    echo -e "$TEST_OUTPUT"
    return 1
  else
    echo -e "\n${GREEN}All tests passed!${NC}"
    return 0
  fi
}

