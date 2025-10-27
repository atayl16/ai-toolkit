#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="${1:-.}"

out_dir="$REPO_ROOT/ai/oss"
mkdir -p "$out_dir"

ctx="$out_dir/context.md"
echo "# OSS Context" > "$ctx"
echo "" >> "$ctx"

# Basic identity
if [ -f "$REPO_ROOT/.git/config" ]; then
  origin=$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || true)
  echo "**Origin:** ${origin:-unknown}" >> "$ctx"
fi
default_branch=$(git -C "$REPO_ROOT" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' || echo "main")
echo "**Default branch:** $default_branch" >> "$ctx"
echo "" >> "$ctx"

# Key docs (truncate long sections)
dump() {
  local p="$1" ttl="$2"
  if [ -f "$REPO_ROOT/$p" ]; then
    echo "## $ttl ($p)" >> "$ctx"
    awk 'NR<=400' "$REPO_ROOT/$p" >> "$ctx"
    echo "" >> "$ctx"
  fi
}

dump "README.md" "README"
dump "CONTRIBUTING.md" "Contributing"
dump "CODE_OF_CONDUCT.md" "Code of Conduct"
dump "docs/CONTRIBUTING.md" "Contributing (docs)"

# Language/tooling signals
echo "## Tooling" >> "$ctx"
[ -f "$REPO_ROOT/.ruby-version" ] && echo "- Ruby: $(cat "$REPO_ROOT/.ruby-version")" >> "$ctx"
[ -f "$REPO_ROOT/Gemfile" ] && echo "- Gemfile present" >> "$ctx"
[ -f "$REPO_ROOT/.rubocop.yml" ] && echo "- RuboCop config present (.rubocop.yml)" >> "$ctx"
[ -f "$REPO_ROOT/package.json" ] && echo "- package.json present" >> "$ctx"
[ -f "$REPO_ROOT/.eslintrc" ] && echo "- ESLint config present" >> "$ctx"
[ -f "$REPO_ROOT/.eslintrc.json" ] && echo "- ESLint (.eslintrc.json)" >> "$ctx"
[ -f "$REPO_ROOT/.editorconfig" ] && echo "- .editorconfig present" >> "$ctx"
[ -d "$REPO_ROOT/.github/workflows" ] && echo "- GitHub Actions workflows present" >> "$ctx"
[ -f "$REPO_ROOT/LICENSE" ] && echo "- License file present" >> "$ctx"
echo "" >> "$ctx"

# Extract lint/test hints
if [ -f "$REPO_ROOT/.rubocop.yml" ]; then
  echo "### RuboCop" >> "$ctx"
  rubyver=$(grep -E "TargetRubyVersion" "$REPO_ROOT/.rubocop.yml" 2>/dev/null | head -1 | awk '{print $2}')
  [ -n "${rubyver:-}" ] && echo "- TargetRubyVersion: $rubyver" >> "$ctx"
  echo "" >> "$ctx"
fi

if [ -f "$REPO_ROOT/package.json" ]; then
  echo "### Node/JS" >> "$ctx"
  node_engine=$(jq -r '.engines.node // empty' "$REPO_ROOT/package.json" 2>/dev/null || true)
  [ -n "${node_engine:-}" ] && echo "- engines.node: $node_engine" >> "$ctx"
  echo "- npm scripts:" >> "$ctx"
  jq -r '.scripts | to_entries[] | "  - \(.key): \(.value)"' "$REPO_ROOT/package.json" 2>/dev/null || true >> "$ctx"
  echo "" >> "$ctx"
fi

# Detect DCO/CLA hints
echo "## Contribution Requirements" >> "$ctx"
if rg -n "Developer Certificate of Origin|DCO" "$REPO_ROOT" -S --hidden --glob '!ai/**' 2>/dev/null | head -1 | grep -q .; then
  echo "- DCO likely required (add Signed-off-by in commits)" >> "$ctx"
fi
if rg -n "Contributor License Agreement|CLA" "$REPO_ROOT" -S --hidden --glob '!ai/**' 2>/dev/null | head -1 | grep -q .; then
  echo "- CLA may be required." >> "$ctx"
fi

# Style guide hints
if rg -n "Conventional Commits|commit message" "$REPO_ROOT" -S --hidden --glob '!ai/**' 2>/dev/null | head -1 | grep -q .; then
  echo "- Commit message conventions documented (see contributing)." >> "$ctx"
fi
echo "" >> "$ctx"

echo "### Quick Rules for AI Pair" >> "$ctx"
cat >> "$ctx" <<'RULES'
- Match repo coding style and linters; do not introduce unrelated refactors.
- Keep PRs small and focused; add/adjust tests.
- Never commit ai/ folder; it's local-only.
- If unsure about API behavior, prefer failing test first.
RULES

echo "Wrote $ctx"

