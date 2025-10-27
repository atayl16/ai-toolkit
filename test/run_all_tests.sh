#!/usr/bin/env bash
# Run all toolkit tests

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              AI Toolkit Test Suite                          ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Track overall results
TOTAL_FAILED=0

# Run unit tests
echo "1. Unit Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if ./test_functions.sh; then
  echo "✓ Functions tests passed"
else
  echo "✗ Functions tests failed"
  TOTAL_FAILED=$((TOTAL_FAILED + 1))
fi
echo ""

# Run template tests
echo "2. Template Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if ./test_template_exists.sh; then
  echo "✓ Template tests passed"
else
  echo "✗ Template tests failed"
  TOTAL_FAILED=$((TOTAL_FAILED + 1))
fi
echo ""

# Summary
echo "╔═══════════════════════════════════════════════════════════════╗"
if [ "$TOTAL_FAILED" -eq 0 ]; then
  echo "║               ✅ ALL TESTS PASSED                          ║"
else
  echo "║               ❌ SOME TESTS FAILED                         ║"
fi
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

exit $TOTAL_FAILED

