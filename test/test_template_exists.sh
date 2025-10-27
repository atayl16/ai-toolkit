#!/usr/bin/env bash
# Verify all templates exist

set -e

# Source test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/unit_test_framework.sh"

TOOLKIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Cleanup function
cleanup() {
  # Remove any test directories/files created during tests
  rm -rf /tmp/test_template_*
}

# Register cleanup
trap cleanup EXIT

test_suite_start "Template Files"

# Rails templates
assert_file_exists ".rubocop.yml" "$TOOLKIT_DIR/templates/rails/.rubocop.yml"
assert_file_exists ".overcommit.yml" "$TOOLKIT_DIR/templates/rails/.overcommit.yml"
assert_file_exists "Justfile" "$TOOLKIT_DIR/templates/rails/Justfile"
assert_file_exists ".erdconfig" "$TOOLKIT_DIR/templates/rails/.erdconfig"
assert_file_exists "bin_setup" "$TOOLKIT_DIR/templates/rails/bin_setup"

# React templates
assert_file_exists ".eslintrc.cjs" "$TOOLKIT_DIR/templates/react/.eslintrc.cjs"
assert_file_exists ".prettierrc" "$TOOLKIT_DIR/templates/react/.prettierrc"
assert_file_exists ".editorconfig" "$TOOLKIT_DIR/templates/react/.editorconfig"

# Security templates
assert_file_exists ".gitleaks.toml" "$TOOLKIT_DIR/templates/security/.gitleaks.toml"

# CI templates
assert_file_exists "rails.yml" "$TOOLKIT_DIR/templates/ci/github/rails.yml"
assert_file_exists "node.yml" "$TOOLKIT_DIR/templates/ci/github/node.yml"

# Prompt templates
assert_file_exists "diagnostic.prompt" "$TOOLKIT_DIR/prompts/diagnostic.prompt"
assert_file_exists "modes.prompt" "$TOOLKIT_DIR/prompts/modes.prompt"

# Summary
test_suite_summary

