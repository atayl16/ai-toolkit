# AI Toolkit - Change Plan

**Date:** 2025-10-24
**Version:** 2.1.0 → 3.0.0
**Goal:** Claude-first, BYOK-enabled, mode-switching developer productivity toolkit

---

## Plan Overview

This plan transforms the AI Toolkit from a Cursor-focused Rails scaffolder into a **vendor-agnostic, Claude-optimized, mode-aware development framework** with first-class BYOK support and robust safety guardrails.

**Principles:**
- Keep changes minimal and well-factored
- No breaking changes to existing workflows
- Small, PR-sized commits
- Verify safety with preflight checks

**Delivery Strategy:**
- GROUP A: Critical (BYOK, Claude integration, mode switching) — blocks v3.0.0
- GROUP B: High Priority (CLI hygiene, testing, docs) — required for v3.0.0
- GROUP C: Medium Priority (React, JobWizard docs, enhancements) — nice-to-have for v3.0.0

---

## GROUP A: Critical (Blocks v3.0.0 Release)

### A1: Add Claude-specific prompts & modes scaffolding

**Rationale:** Current modes documented but not activatable. Need generator to inject mode-specific prompts into per-repo context.

**Affected Files:**
- **New:** `bin/ai-mode` (generator script)
- **New:** `prompts/modes/driver.prompt`
- **New:** `prompts/modes/approval.prompt`
- **New:** `prompts/modes/autopilot.prompt`
- **New:** `prompts/utilities/review-diff.prompt`
- **New:** `prompts/utilities/ui-iterate.prompt`
- **New:** `prompts/utilities/bug-loop-breaker.prompt`
- **New:** `prompts/utilities/refactor-plan.prompt`
- **New:** `prompts/utilities/session-kickoff.prompt`
- **Modified:** `bin/functions.sh` (add `ai_set_mode` function)
- **Modified:** `templates/claude.md` (add mode injection section)

**Implementation:**

1. Create `prompts/modes/driver.prompt`:
```markdown
# DRIVER MODE

You are in DRIVER mode. The developer writes code; you review and suggest.

## Your Role
- REVIEW code written by developer
- SUGGEST improvements (don't implement without approval)
- GENERATE small bits only when explicitly requested (e.g., migrations, tests)
- ASK clarifying questions before any generation

## Rules
- DO NOT write large code blocks unsolicited
- DO provide inline code suggestions in review comments
- DO point out bugs, security risks, missing tests
- DO suggest architectural improvements
- WAIT for developer approval before implementing suggestions

## Output Format
- Use review checklist (BLOCKERS, NITS, RISKS)
- Provide actionable feedback with line numbers
- Suggest fixes but don't apply them
```

2. Create `prompts/modes/approval.prompt`:
```markdown
# APPROVAL MODE

You are in APPROVAL mode. You plan and propose diffs; developer approves subsets before changes.

## Your Role
- CREATE structured plans with labeled items (A1, A2, B1, B2, ...)
- PROPOSE diffs for approved items only
- WAIT for "Approve: A1, B3..." before implementing
- COMMIT small, reviewable changes

## Workflow
1. PLAN: Create ai/plans/YYYYMMDD-feature.md with labeled items
2. WAIT: Developer responds with "Approve: A1, A2..." or asks questions
3. IMPLEMENT: Only approved items, one at a time (~200 LOC max)
4. SHOW: Unified diffs before applying
5. VERIFY: Suggest test/lint commands (don't auto-run)
6. REPEAT: Mark complete, move to next approved item

## Rules
- DO NOT implement without explicit approval
- DO break large features into small items (A1, A2, A3...)
- DO provide clear rationale for each item
- DO estimate size/risk for each item
- WAIT for feedback before proceeding

## Output Format
Plans use this structure:
```
## GROUP A: Core Functionality
- **A1:** Description (Rationale: why needed, Risk: low/med/high, Size: S/M/L)
- **A2:** Description (...)

## GROUP B: Testing
- **B1:** Description (...)
```

When approved:
```
Implementing A1...
[Show diff]
Verification: `bundle exec rspec spec/models/user_spec.rb`
```
```

3. Create `prompts/modes/autopilot.prompt`:
```markdown
# AUTOPILOT MODE

You are in AUTOPILOT mode. You implement end-to-end, asking only if blocked.

## Your Role
- IMPLEMENT features/fixes completely
- MAKE reasonable decisions autonomously
- ASK only if truly blocked (ambiguous requirements, missing context, breaking changes)
- COMMIT incrementally with clear messages

## Workflow
1. UNDERSTAND: Analyze request, identify steps
2. IMPLEMENT: Write code, tests, docs
3. VERIFY: Run linters, tests (suggest commands, don't auto-run)
4. COMMIT: Small commits (~200 LOC each) with "feat/fix/refactor: ..." messages
5. REPORT: Summarize what was done, what to verify

## Rules
- DO implement without asking for minor decisions (naming, file structure, etc.)
- DO ask if requirements ambiguous or breaking changes needed
- DO follow project conventions (RuboCop, ESLint, test patterns)
- DO write tests for new functionality
- DO keep commits small and atomic

## When to Ask
- Ambiguous requirements (multiple valid interpretations)
- Breaking changes (API changes, config changes, migrations)
- Missing context (no similar code to reference, unclear business rules)
- Risky operations (data deletion, security changes, deploy steps)

## Output Format
After implementing:
```
✅ Implemented: <Feature Name>

Changes:
- Added X (file.rb:123)
- Updated Y (file.rb:456)
- Tests: Z (spec/file_spec.rb)

Verification:
- `bundle exec rspec`
- `bundle exec rubocop`
- `just test`

Next Steps:
- Review changes in git diff
- Run verification commands
- Commit if satisfied
```
```

4. Create `prompts/utilities/session-kickoff.prompt`:
```markdown
# SESSION KICKOFF

Welcome! This project uses AI Toolkit with structured workflows.

## Available Modes

### DRIVER MODE (You Write, AI Reviews)
- You write code, AI reviews and suggests
- AI generates small bits only when requested (migrations, tests)
- Best for: Learning, tight control, code walkthroughs

### APPROVAL MODE (AI Plans, You Approve)
- AI creates plan with labeled items (A1, A2, B1, B2...)
- You reply "Approve: A1, B3..." to select which to implement
- AI implements only approved items
- Best for: Feature development, refactoring, bug fixes

### AUTOPILOT MODE (AI Implements End-to-End)
- AI implements completely, asks only if blocked
- Small commits (~200 LOC each)
- Best for: Prototypes, repetitive tasks, well-defined features

## Current Mode
[INJECTED BY bin/ai-mode]

## Project Context
Repository: [INJECTED]
Stack: [INJECTED]
Style: [INJECTED]
Conventions: [INJECTED]

## Commands
- `dev plan "Feature"` — Create new plan
- `dev scans` — Run security/quality scans
- `just test` — Run tests
- `just lint-fix` — Auto-fix linting
- `scan_here` — Quick security check

## Getting Started
Describe what you'd like to work on, and I'll proceed in [CURRENT_MODE] mode.
```

5. Create `prompts/utilities/bug-loop-breaker.prompt`:
```markdown
# BUG LOOP BREAKER

You are stuck in a bug fix loop. STOP implementing and use this diagnostic process.

## Process: TRACE → PROVE → CLASSIFY → PROPOSE

### 1. TRACE (Understand the Symptom)
- What is the EXACT error message or unexpected behavior?
- Where does it manifest? (console, logs, UI, tests)
- What is the MINIMAL reproduction case?
- What input causes it? What input doesn't?

### 2. PROVE (Capture Failing Evidence)
Create ONE of these:
- Failing test that demonstrates the bug
- Console script that reproduces the issue
- Request/response pair showing the problem
- Screenshot + steps to reproduce

**DO NOT PROCEED** without provable reproduction.

### 3. CLASSIFY (Root Cause Analysis)
Analyze the failing evidence:
- Logic bug (wrong condition, off-by-one, null handling)
- Data issue (missing record, wrong association, constraint violation)
- Environment (missing gem, wrong version, config issue)
- Assumption (misunderstood requirement, API contract mismatch)

Identify the SINGLE root cause (not symptoms).

### 4. PROPOSE (Fix Strategy)
Propose fix with:
- Root cause: "The issue is X because Y"
- Fix: "Change Z in file.rb:123 to W"
- Test: "This test will pass after fix: ..."
- Confidence: High/Medium/Low

**DO NOT IMPLEMENT YET.** Wait for approval.

## Rules
- NO trial-and-error fixes
- NO "let's try..." or "maybe..."
- REQUIRE reproduction before diagnosis
- ONE root cause, ONE fix
- WAIT for approval before editing code

## Output Format
```
## TRACE
Error: <exact message>
Location: <file:line or UI location>
Reproduction: <minimal case>

## PROVE
[Failing test | Console script | Request/response | Screenshot]

## CLASSIFY
Root Cause: <single cause>
Category: Logic bug | Data issue | Environment | Assumption
Analysis: <why this is the root cause>

## PROPOSE
Fix: <specific change>
File: <file.rb:line>
Test: <verification>
Confidence: High | Medium | Low
```
```

6. Create `bin/ai-mode` (generator script):
```bash
#!/usr/bin/env bash
set -euo pipefail

# Usage: dev mode [driver|approval|autopilot]
# Creates per-repo AI mode configuration and planning structure

TOOLKIT_DIR="${TOOLKIT_DIR:-$HOME/.ai-toolkit}"
MODE="${1:-}"

usage() {
  cat <<EOF
Usage: dev mode [driver|approval|autopilot]

Modes:
  driver      You write code, AI reviews and suggests
  approval    AI plans, you approve subsets (A1, B3...)
  autopilot   AI implements end-to-end, asks only if blocked

Examples:
  dev mode approval    # Set APPROVAL mode for this project
  dev mode             # Show current mode
EOF
}

show_current_mode() {
  if [[ -f ai/mode.txt ]]; then
    CURRENT=$(cat ai/mode.txt)
    echo "Current mode: $CURRENT"
    echo "To change: dev mode [driver|approval|autopilot]"
  else
    echo "No mode set. Run: dev mode [driver|approval|autopilot]"
  fi
}

set_mode() {
  local mode="$1"

  # Validate mode
  case "$mode" in
    driver|approval|autopilot) ;;
    *)
      echo "Error: Invalid mode '$mode'"
      usage
      exit 1
      ;;
  esac

  # Create ai/ directory structure
  mkdir -p ai/plans ai/tracking

  # Write mode
  echo "$mode" > ai/mode.txt

  # Copy mode-specific prompt
  cp "$TOOLKIT_DIR/prompts/modes/${mode}.prompt" ai/mode-${mode}.prompt

  # Copy session kickoff template
  cp "$TOOLKIT_DIR/prompts/utilities/session-kickoff.prompt" ai/session-kickoff.md

  # Inject current mode into session kickoff
  sed -i.bak "s/\[CURRENT_MODE\]/$mode/g" ai/session-kickoff.md
  rm ai/session-kickoff.md.bak

  # Create tracking template
  cat > ai/tracking.md <<EOF
# AI Toolkit Tracking

**Mode:** $mode
**Updated:** $(date +%Y-%m-%d)

## In Progress
- [ ] (none)

## Completed
- (none yet)

## Deferred
- (none)

## Open Questions
- (none)
EOF

  echo "✅ Mode set to: $mode"
  echo ""
  echo "Created:"
  echo "  - ai/mode.txt (current mode)"
  echo "  - ai/mode-${mode}.prompt (mode-specific prompt)"
  echo "  - ai/session-kickoff.md (session kickoff template)"
  echo "  - ai/tracking.md (progress tracking)"
  echo ""
  echo "Next: Share ai/session-kickoff.md with AI to start session"
}

# Main
if [[ -z "$MODE" ]]; then
  show_current_mode
else
  set_mode "$MODE"
fi
```

7. Update `bin/functions.sh` to add `ai_set_mode`:
```bash
ai_set_mode() {
  "$TOOLKIT_DIR/bin/ai-mode" "$@"
}
```

8. Update `bin/dev` to add `mode` subcommand:
```bash
# In subcommand case statement
mode)
  ai_set_mode "$@"
  ;;
```

**Test Plan:**
1. Run `dev mode approval` in test project
2. Verify `ai/mode.txt`, `ai/mode-approval.prompt`, `ai/session-kickoff.md`, `ai/tracking.md` created
3. Verify session kickoff contains "APPROVAL MODE"
4. Repeat for `driver` and `autopilot`
5. Verify `dev mode` shows current mode

**Risk:** Low — new functionality, doesn't break existing workflows

**Size:** Medium (~300 LOC across multiple files)

---

### A2: Create provider adapters (anthropic.rb + openai.rb)

**Rationale:** No vendor abstraction. Need thin wrappers for BYOK with Anthropic/OpenAI.

**Affected Files:**
- **New:** `providers/anthropic.rb`
- **New:** `providers/openai.rb`
- **New:** `providers/README.md`
- **Modified:** `bin/preflight` (check for API keys)

**Implementation:**

1. Create `providers/anthropic.rb`:
```ruby
# frozen_string_literal: true

require "net/http"
require "json"

module AIToolkit
  module Providers
    class Anthropic
      API_BASE = "https://api.anthropic.com/v1"
      DEFAULT_MODEL = "claude-sonnet-4-5-20250929"

      def initialize(api_key: nil)
        @api_key = api_key || ENV["ANTHROPIC_API_KEY"]
        raise ArgumentError, "ANTHROPIC_API_KEY not set" if @api_key.nil? || @api_key.empty?
      end

      def chat(messages:, model: DEFAULT_MODEL, max_tokens: 4096, temperature: 1.0)
        uri = URI("#{API_BASE}/messages")
        request = Net::HTTP::Post.new(uri)
        request["x-api-key"] = @api_key
        request["anthropic-version"] = "2023-06-01"
        request["content-type"] = "application/json"

        request.body = JSON.generate({
          model: model,
          messages: messages,
          max_tokens: max_tokens,
          temperature: temperature
        })

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        unless response.is_a?(Net::HTTPSuccess)
          raise "API error: #{response.code} #{response.body}"
        end

        JSON.parse(response.body)
      end

      def available_models
        [
          "claude-sonnet-4-5-20250929",
          "claude-sonnet-4-20250514",
          "claude-opus-4-20250514",
          "claude-3-5-sonnet-20241022",
          "claude-3-5-haiku-20241022"
        ]
      end
    end
  end
end
```

2. Create `providers/openai.rb`:
```ruby
# frozen_string_literal: true

require "net/http"
require "json"

module AIToolkit
  module Providers
    class OpenAI
      API_BASE = "https://api.openai.com/v1"
      DEFAULT_MODEL = "gpt-4-turbo-preview"

      def initialize(api_key: nil)
        @api_key = api_key || ENV["OPENAI_API_KEY"]
        raise ArgumentError, "OPENAI_API_KEY not set" if @api_key.nil? || @api_key.empty?
      end

      def chat(messages:, model: DEFAULT_MODEL, max_tokens: 4096, temperature: 1.0)
        uri = URI("#{API_BASE}/chat/completions")
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{@api_key}"
        request["Content-Type"] = "application/json"

        request.body = JSON.generate({
          model: model,
          messages: messages,
          max_tokens: max_tokens,
          temperature: temperature
        })

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        unless response.is_a?(Net::HTTPSuccess)
          raise "API error: #{response.code} #{response.body}"
        end

        JSON.parse(response.body)
      end

      def available_models
        [
          "gpt-4-turbo-preview",
          "gpt-4",
          "gpt-3.5-turbo"
        ]
      end
    end
  end
end
```

3. Create `providers/README.md`:
```markdown
# AI Providers

Thin wrappers for LLM APIs. Supports BYOK (Bring Your Own Key).

## Supported Providers

### Anthropic (Claude)
**Recommended for coding tasks.**

Setup:
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

Recommended model: `claude-sonnet-4-5-20250929`

Usage:
```ruby
require_relative "providers/anthropic"
client = AIToolkit::Providers::Anthropic.new
response = client.chat(messages: [{ role: "user", content: "Hello" }])
```

### OpenAI (GPT)
**Alternate provider.**

Setup:
```bash
export OPENAI_API_KEY="sk-..."
```

Recommended model: `gpt-4-turbo-preview`

Usage:
```ruby
require_relative "providers/openai"
client = AIToolkit::Providers::OpenAI.new
response = client.chat(messages: [{ role: "user", content: "Hello" }])
```

## Security

- **NEVER commit API keys** to version control
- **NEVER print API keys** in logs or error messages
- **ALWAYS** use environment variables
- **VERIFY** `.env` is in `.gitignore`

Run `dev preflight` to check for leaked secrets.
```

**Test Plan:**
1. Set `ANTHROPIC_API_KEY` in shell
2. Run Ruby script: `ruby -r ./providers/anthropic -e "puts AIToolkit::Providers::Anthropic.new.available_models"`
3. Verify no errors
4. Repeat for OpenAI
5. Verify missing key raises error

**Risk:** Low — new files, no dependencies on existing code

**Size:** Small (~150 LOC total)

---

### A3: BYOK docs + safety (env var checks, gitignore verification)

**Rationale:** No documentation for setting up API keys. Need setup guide + preflight checks.

**Affected Files:**
- **New:** `docs/CLAUDE_SETUP.md`
- **New:** `bin/preflight` (safety checks)
- **Modified:** `bin/functions.sh` (add `run_preflight` function)
- **Modified:** `bin/dev` (call preflight in `bootstrap`)
- **Modified:** `README.md` (add link to CLAUDE_SETUP.md)

**Implementation:**

1. Create `docs/CLAUDE_SETUP.md`:
```markdown
# Claude Setup Guide

This guide explains how to use Claude (Anthropic's LLM) with AI Toolkit in Cursor or Claude Code.

## Why Claude?

**Claude is optimized for coding tasks:**
- Strong reasoning and planning
- Large context window (200K tokens)
- Excellent at following structured workflows
- Safe and accurate code generation

**Recommended model:** `claude-sonnet-4-5-20250929`

---

## Option 1: Cursor IDE (BYOK)

### Step 1: Get Anthropic API Key

1. Go to [Anthropic Console](https://console.anthropic.com/)
2. Sign up or log in
3. Navigate to **API Keys**
4. Create new key: "Cursor Development"
5. Copy key (starts with `sk-ant-...`)

### Step 2: Add Key to Cursor

**Method A: Cursor Settings (Recommended)**
1. Open Cursor
2. Go to **Settings** (Cmd+, or Ctrl+,)
3. Navigate to **Accounts & Models**
4. Under **Anthropic**, click **Add API Key**
5. Paste your key
6. Select model: `claude-sonnet-4-5-20250929`

**Method B: Environment Variable**
1. Add to `~/.zshrc` (or `~/.bashrc`):
   ```bash
   export ANTHROPIC_API_KEY="sk-ant-..."
   ```
2. Restart terminal
3. Restart Cursor

### Step 3: Verify Setup

1. Open any project in Cursor
2. Open Cursor Chat (Cmd+L)
3. Type: "Hello, which model are you?"
4. Verify response mentions Claude

---

## Option 2: Claude Code IDE

### Step 1: Get Anthropic API Key

Same as Option 1, Step 1.

### Step 2: Add Key to Claude Code

1. Open Claude Code
2. Go to **Settings**
3. Navigate to **API Keys**
4. Click **Add Key** → **Anthropic**
5. Paste your key
6. Select model: `claude-sonnet-4-5-20250929`

### Step 3: Verify Setup

1. Open any project in Claude Code
2. Open chat panel
3. Type: "Hello, which model are you?"
4. Verify response mentions Claude

---

## Option 3: Environment Variables (CLI Tools)

Some AI Toolkit scripts may use providers directly (e.g., for automation).

### Step 1: Add to Shell Config

Add to `~/.zshrc` (or `~/.bashrc`):
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."  # Optional, for alternate provider
```

### Step 2: Reload Shell

```bash
source ~/.zshrc
```

### Step 3: Verify

```bash
echo $ANTHROPIC_API_KEY  # Should print sk-ant-...
```

**⚠️ WARNING:** Do NOT add keys to project `.env` files that might be committed.

---

## Security Best Practices

### ✅ DO

- Store keys in shell config (`~/.zshrc`) or IDE settings
- Use `.env.local` for project-specific overrides (gitignored)
- Run `dev preflight` to check for leaked secrets
- Rotate keys if accidentally committed

### ❌ DO NOT

- Commit keys to `.env` or any tracked file
- Print keys in logs or error messages
- Share keys in screenshots or screencasts
- Use keys from untrusted sources

### Verify Gitignore

Run this before committing:
```bash
dev preflight
```

This checks:
- `.env` is gitignored
- No `*_API_KEY` in tracked files
- Gitleaks scan passes

---

## Model Selection

### Anthropic Models (Recommended)

| Model | Best For | Context | Cost |
|-------|----------|---------|------|
| `claude-sonnet-4-5-20250929` | **Coding** (recommended) | 200K | $$ |
| `claude-opus-4-20250514` | Complex reasoning | 200K | $$$ |
| `claude-3-5-haiku-20241022` | Fast iterations | 200K | $ |

### OpenAI Models (Alternate)

| Model | Best For | Context | Cost |
|-------|----------|---------|------|
| `gpt-4-turbo-preview` | General coding | 128K | $$ |
| `gpt-4` | Legacy projects | 8K | $$$ |

**Recommendation:** Use `claude-sonnet-4-5-20250929` for best results.

---

## Troubleshooting

### "ANTHROPIC_API_KEY not set"

**Cause:** Key not found in environment or IDE settings.

**Fix:**
1. Verify key in `~/.zshrc`: `echo $ANTHROPIC_API_KEY`
2. If missing, add: `export ANTHROPIC_API_KEY="sk-ant-..."`
3. Reload: `source ~/.zshrc`
4. Restart IDE

### "API error: 401 Unauthorized"

**Cause:** Invalid or expired API key.

**Fix:**
1. Generate new key at [Anthropic Console](https://console.anthropic.com/)
2. Update `~/.zshrc` or IDE settings
3. Restart IDE

### "API error: 429 Too Many Requests"

**Cause:** Rate limit exceeded.

**Fix:**
1. Wait 1-2 minutes
2. Reduce request frequency
3. Upgrade Anthropic plan if persistent

### Keys Accidentally Committed

**Fix:**
1. Rotate key immediately at [Anthropic Console](https://console.anthropic.com/)
2. Remove from git history:
   ```bash
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch .env" \
     --prune-empty --tag-name-filter cat -- --all
   ```
3. Force push: `git push origin --force --all`
4. Notify team to pull latest

---

## Next Steps

1. ✅ Setup API key (above)
2. 📖 Read [Cursor Guide](CURSOR_GUIDE.md)
3. 🚀 Set AI mode: `dev mode approval`
4. 🛠️ Start building: `dev plan "Feature Name"`
```

2. Create `bin/preflight`:
```bash
#!/usr/bin/env bash
set -euo pipefail

# Preflight checks: secrets safety, gitignore, dependencies
# Usage: dev preflight

TOOLKIT_DIR="${TOOLKIT_DIR:-$HOME/.ai-toolkit}"

red() { echo -e "\033[0;31m$*\033[0m"; }
green() { echo -e "\033[0;32m$*\033[0m"; }
yellow() { echo -e "\033[0;33m$*\033[0m"; }

echo "🔍 Running preflight checks..."
echo ""

ERRORS=0

# Check 1: .env is gitignored
if [[ -f .env ]]; then
  if git check-ignore .env &>/dev/null; then
    green "✅ .env is gitignored"
  else
    red "❌ .env is NOT gitignored (security risk!)"
    echo "   Fix: Add '.env' to .gitignore"
    ERRORS=$((ERRORS + 1))
  fi
else
  yellow "⚠️  No .env file found (OK if not using)"
fi

# Check 2: No API keys in tracked files
if git grep -E '(ANTHROPIC_API_KEY|OPENAI_API_KEY|sk-ant-|sk-)' -- '*.rb' '*.sh' '*.yml' '*.yaml' '*.json' &>/dev/null; then
  red "❌ Possible API keys found in tracked files!"
  echo "   Files:"
  git grep -l -E '(ANTHROPIC_API_KEY|OPENAI_API_KEY|sk-ant-|sk-)' -- '*.rb' '*.sh' '*.yml' '*.yaml' '*.json' || true
  echo "   Fix: Remove keys, add to .env (gitignored)"
  ERRORS=$((ERRORS + 1))
else
  green "✅ No API keys in tracked files"
fi

# Check 3: Gitleaks available
if command -v gitleaks &>/dev/null; then
  green "✅ Gitleaks installed"

  # Run gitleaks scan
  if gitleaks detect --no-git --quiet &>/dev/null; then
    green "✅ Gitleaks scan passed (no secrets detected)"
  else
    red "❌ Gitleaks found potential secrets!"
    echo "   Run: gitleaks detect --no-git --report-path reports/gitleaks.json"
    echo "   Review: cat reports/gitleaks.json"
    ERRORS=$((ERRORS + 1))
  fi
else
  yellow "⚠️  Gitleaks not installed (recommended for secret scanning)"
  echo "   Install: brew install gitleaks"
fi

# Check 4: Overcommit hooks installed
if [[ -f .overcommit.yml ]]; then
  if [[ -f .git/hooks/pre-commit ]] && grep -q "overcommit" .git/hooks/pre-commit 2>/dev/null; then
    green "✅ Overcommit hooks installed"
  else
    yellow "⚠️  Overcommit config exists but hooks not installed"
    echo "   Fix: bundle exec overcommit --install"
  fi
else
  yellow "⚠️  No .overcommit.yml (OK if not using)"
fi

# Check 5: API keys available (if providers exist)
if [[ -d "$TOOLKIT_DIR/providers" ]]; then
  if [[ -n "${ANTHROPIC_API_KEY:-}" ]] || [[ -n "${OPENAI_API_KEY:-}" ]]; then
    green "✅ API keys found in environment"
  else
    yellow "⚠️  No API keys found (ANTHROPIC_API_KEY, OPENAI_API_KEY)"
    echo "   See: docs/CLAUDE_SETUP.md for setup instructions"
  fi
fi

echo ""
if [[ $ERRORS -eq 0 ]]; then
  green "✅ All preflight checks passed!"
  exit 0
else
  red "❌ $ERRORS preflight check(s) failed"
  echo ""
  echo "Fix issues above before committing."
  exit 1
fi
```

3. Update `bin/functions.sh`:
```bash
run_preflight() {
  "$TOOLKIT_DIR/bin/preflight"
}
```

4. Update `bin/dev`:
```bash
# In subcommand case statement
preflight)
  run_preflight
  ;;

# In bootstrap command
bootstrap)
  run_preflight || echo "⚠️  Preflight warnings (non-blocking)"
  ai_bootstrap_repo
  ;;
```

5. Update `README.md`:
```markdown
## Setup

1. Clone toolkit: `git clone https://github.com/yourusername/ai-toolkit ~/.ai-toolkit`
2. Add to PATH: `echo 'export PATH="$HOME/.ai-toolkit/bin:$PATH"' >> ~/.zshrc`
3. Setup API keys: See [Claude Setup Guide](docs/CLAUDE_SETUP.md)
4. Run preflight: `dev preflight`
5. Create first project: `dev new rails MyApp`
```

**Test Plan:**
1. Create test repo with `.env` containing `ANTHROPIC_API_KEY=sk-ant-test`
2. Run `dev preflight`
3. Verify error: ".env is NOT gitignored"
4. Add `.env` to `.gitignore`
5. Run `dev preflight`
6. Verify passes
7. Add `ANTHROPIC_API_KEY=sk-ant-test` to `config.yml`
8. Run `dev preflight`
9. Verify error: "API keys found in tracked files"

**Risk:** Low — new functionality, non-blocking in bootstrap

**Size:** Medium (~250 LOC across multiple files)

---

### A4: Refactor "dev" CLI into composable functions, add shellcheck tests

**Rationale:** `bin/dev` is 615 lines with inline logic. Hard to test. Need modular functions + shellcheck validation.

**Affected Files:**
- **Modified:** `bin/dev` (extract subcommands into functions)
- **Modified:** `bin/functions.sh` (move extracted functions here)
- **New:** `bin/test_shell` (shellcheck runner)
- **Modified:** `test/run_all_tests.sh` (add shellcheck)

**Implementation:**

1. Refactor `bin/dev` subcommands into functions in `bin/functions.sh`:

Extract these blocks:
- `dev new rails` → `new_rails_app()`
- `dev new rails-react` → `new_rails_react_app()`
- `dev bootstrap` → `ai_bootstrap_repo()` (already exists)
- `dev plan` → `ai_new_plan()` (already exists)
- `dev scans` → `scan_here()` (already exists)
- `dev stack up/down` → `stack_up()`, `stack_down()` (already exist)
- `dev sandbox` → `new_interview()` (already exists)
- `dev oss init/issues/plan/...` → `oss_init()`, `oss_issues()`, etc.

After refactor, `bin/dev` becomes thin dispatcher:
```bash
#!/usr/bin/env bash
set -euo pipefail

TOOLKIT_DIR="${TOOLKIT_DIR:-$HOME/.ai-toolkit}"
source "$TOOLKIT_DIR/bin/functions.sh"

SUBCOMMAND="${1:-help}"
shift || true

case "$SUBCOMMAND" in
  new) new_project "$@" ;;
  bootstrap) run_preflight || true; ai_bootstrap_repo ;;
  plan) ai_new_plan "$@" ;;
  scans) scan_here ;;
  stack) stack_command "$@" ;;
  sandbox) new_interview "$@" ;;
  oss) oss_command "$@" ;;
  mode) ai_set_mode "$@" ;;
  preflight) run_preflight ;;
  help|--help|-h) show_help ;;
  *) echo "Unknown command: $SUBCOMMAND"; show_help; exit 1 ;;
esac
```

2. Create `bin/test_shell`:
```bash
#!/usr/bin/env bash
set -euo pipefail

# Run shellcheck on all shell scripts

TOOLKIT_DIR="${TOOLKIT_DIR:-$HOME/.ai-toolkit}"

if ! command -v shellcheck &>/dev/null; then
  echo "❌ shellcheck not installed"
  echo "Install: brew install shellcheck"
  exit 1
fi

echo "🔍 Running shellcheck..."

ERRORS=0

for script in "$TOOLKIT_DIR"/bin/*.sh "$TOOLKIT_DIR"/bin/dev "$TOOLKIT_DIR"/bin/preflight "$TOOLKIT_DIR"/bin/ai-mode "$TOOLKIT_DIR"/oss/*.sh; do
  if [[ -f "$script" ]]; then
    echo "Checking: $script"
    if shellcheck "$script"; then
      echo "✅ Passed"
    else
      echo "❌ Failed"
      ERRORS=$((ERRORS + 1))
    fi
    echo ""
  fi
done

if [[ $ERRORS -eq 0 ]]; then
  echo "✅ All shellcheck tests passed!"
  exit 0
else
  echo "❌ $ERRORS shellcheck test(s) failed"
  exit 1
fi
```

3. Update `test/run_all_tests.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Running all tests..."

ERRORS=0

# Unit tests
if bash test/test_functions.sh; then
  echo "✅ Unit tests passed"
else
  echo "❌ Unit tests failed"
  ERRORS=$((ERRORS + 1))
fi

# Template existence tests
if bash test/test_template_exists.sh; then
  echo "✅ Template tests passed"
else
  echo "❌ Template tests failed"
  ERRORS=$((ERRORS + 1))
fi

# Shellcheck tests
if bash bin/test_shell; then
  echo "✅ Shellcheck tests passed"
else
  echo "❌ Shellcheck tests failed"
  ERRORS=$((ERRORS + 1))
fi

if [[ $ERRORS -eq 0 ]]; then
  echo "✅ All tests passed!"
  exit 0
else
  echo "❌ $ERRORS test suite(s) failed"
  exit 1
fi
```

**Test Plan:**
1. Run `bin/test_shell`
2. Verify shellcheck passes for all scripts
3. Introduce syntax error in `bin/dev`
4. Run `bin/test_shell`
5. Verify failure detected
6. Fix error
7. Run `test/run_all_tests.sh`
8. Verify all tests pass

**Risk:** Medium — refactoring existing code, but functions already mostly extracted

**Size:** Medium (~200 LOC changes across multiple files)

---

### A5: Doc consolidation (README/QUICKSTART/CHEATSHEET/WORKFLOWS) + single TOC

**Rationale:** Docs are comprehensive but fragmented. Hard to find info. Need single entry point.

**Affected Files:**
- **New:** `docs/TOC.md` (table of contents)
- **Modified:** `README.md` (shorten, link to TOC)
- **Modified:** `QUICKSTART.md` (shorten to <50 lines)
- **Modified:** `CHEATSHEET.md` (organize by workflow)
- **New:** `docs/WHERE_TO_START.md` (decision tree)

**Implementation:**

1. Create `docs/TOC.md`:
```markdown
# AI Toolkit - Documentation Index

**Version:** 3.0.0
**Updated:** 2025-10-24

---

## 🚀 Getting Started

| Doc | Purpose | Time |
|-----|---------|------|
| [README](../README.md) | Overview, installation, philosophy | 5 min |
| [QUICKSTART](../QUICKSTART.md) | Create first app in 5 minutes | 5 min |
| [INSTALL](../INSTALL.md) | Detailed installation instructions | 10 min |
| [WHERE TO START](WHERE_TO_START.md) | Decision tree for your use case | 2 min |

---

## 🤖 AI Integration

| Doc | Purpose | Time |
|-----|---------|------|
| [CLAUDE_SETUP](CLAUDE_SETUP.md) | Setup API keys (BYOK) | 10 min |
| [CURSOR_GUIDE](CURSOR_GUIDE.md) | Cursor/Claude Code configuration | 10 min |
| [AI_GUARDRAILS](AI_GUARDRAILS.md) | Privacy, truth-only, local-first | 5 min |
| [AI Modes](../prompts/modes/) | driver, approval, autopilot | 5 min |

---

## 📚 Reference

| Doc | Purpose | Time |
|-----|---------|------|
| [CHEATSHEET](../CHEATSHEET.md) | Quick command reference | 2 min |
| [WORKFLOWS](../WORKFLOWS.md) | Real-world recipes | 10 min |
| [TEMPLATE_TIERS](TEMPLATE_TIERS.md) | Gem tiering strategy | 5 min |

---

## 🔧 Advanced

| Doc | Purpose | Time |
|-----|---------|------|
| [CONTRIBUTING](../CONTRIBUTING.md) | Contribution guidelines | 10 min |
| [UPGRADE_NOTES](../UPGRADE_NOTES.md) | Version migration guide | 5 min |
| [CHANGELOG](../CHANGELOG.md) | Version history | 2 min |

---

## 🎯 Quick Links

### I want to...

- **Start a new Rails app** → [QUICKSTART](../QUICKSTART.md)
- **Setup Claude API key** → [CLAUDE_SETUP](CLAUDE_SETUP.md)
- **Switch AI modes** → `dev mode approval`
- **Review candidate code safely** → `dev sandbox <repo>`
- **Contribute to OSS project** → `dev oss init owner/repo`
- **Run security scans** → `dev scans`
- **Fix a bug with AI** → `dev plan "Fix bug X"` + [WORKFLOWS](../WORKFLOWS.md)

### I need help with...

- **Commands** → [CHEATSHEET](../CHEATSHEET.md)
- **Workflows** → [WORKFLOWS](../WORKFLOWS.md)
- **Installation** → [INSTALL](../INSTALL.md)
- **API keys** → [CLAUDE_SETUP](CLAUDE_SETUP.md)
- **Cursor setup** → [CURSOR_GUIDE](CURSOR_GUIDE.md)

---

## 📂 Repository Structure

```
.ai-toolkit/
├── bin/                # CLI commands
├── prompts/            # AI prompts (modes + utilities)
├── templates/          # Rails/React/JobWizard configs
├── ai/                 # System prompts (charter, constraints)
├── providers/          # API wrappers (Anthropic, OpenAI)
├── docs/               # Documentation
└── [README, QUICKSTART, CHEATSHEET, WORKFLOWS]
```

---

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| "Command not found: dev" | Add to PATH: `export PATH="$HOME/.ai-toolkit/bin:$PATH"` |
| "ANTHROPIC_API_KEY not set" | See [CLAUDE_SETUP](CLAUDE_SETUP.md) |
| "Preflight checks failed" | Run: `dev preflight` and fix issues |
| "Mode not set" | Run: `dev mode approval` |

---

## 📖 External Resources

- [Anthropic API Docs](https://docs.anthropic.com/)
- [Cursor IDE Docs](https://docs.cursor.sh/)
- [Claude Code Docs](https://docs.claude.com/)
- [RuboCop Docs](https://rubocop.org/)
- [RSpec Docs](https://rspec.info/)
```

2. Create `docs/WHERE_TO_START.md`:
```markdown
# Where to Start?

**Choose your path:**

---

## 🆕 I'm new to AI Toolkit

1. Read [README](../README.md) (5 min)
2. Install: [INSTALL](../INSTALL.md) (10 min)
3. Setup Claude: [CLAUDE_SETUP](docs/CLAUDE_SETUP.md) (10 min)
4. Create first app: [QUICKSTART](../QUICKSTART.md) (5 min)
5. Learn workflows: [WORKFLOWS](../WORKFLOWS.md) (10 min)

**Total time:** ~40 minutes

---

## 🚀 I want to start a new project

**Rails app:**
```bash
dev new rails MyApp
cd MyApp
dev mode approval
dev plan "First feature"
```

**Rails API + React:**
```bash
dev new rails-react MyApp
cd MyApp
dev mode approval
```

**JobWizard (job tracking):**
```bash
dev new jobwizard MyJobApp
cd MyJobApp
```

---

## 🤖 I want to use AI assistance

### Step 1: Setup API key
See [CLAUDE_SETUP](CLAUDE_SETUP.md)

### Step 2: Choose AI mode

| Mode | When to Use |
|------|-------------|
| **driver** | You write code, AI reviews |
| **approval** | AI plans, you approve subsets |
| **autopilot** | AI implements end-to-end |

```bash
dev mode approval  # Recommended for most workflows
```

### Step 3: Start working
```bash
dev plan "Feature Name"  # Creates ai/plans/*.md
# AI creates plan with labeled items (A1, A2, B1...)
# Reply: "Approve: A1, A2" to implement
```

See [WORKFLOWS](../WORKFLOWS.md) for detailed recipes.

---

## 🔍 I want to review code safely

**Interview candidate code:**
```bash
dev sandbox https://github.com/candidate/code-challenge
cd ~/Desktop/interviews/code-challenge/
# Isolated Docker env with security scans
```

**OSS contribution:**
```bash
dev oss init owner/repo
dev oss issues owner/repo
dev oss plan "Fix issue #123"
```

---

## 📖 I need a reference

**Quick commands:**
→ [CHEATSHEET](../CHEATSHEET.md)

**Real-world recipes:**
→ [WORKFLOWS](../WORKFLOWS.md)

**All docs:**
→ [TOC](TOC.md)

---

## 🆘 I have a problem

**Installation issues:**
→ [INSTALL](../INSTALL.md) → Troubleshooting section

**API key issues:**
→ [CLAUDE_SETUP](CLAUDE_SETUP.md) → Troubleshooting section

**Command errors:**
→ Run `dev preflight` to diagnose

**AI stuck in bug loop:**
→ Run `ai_diagnose` (uses diagnostic.prompt)

**Other issues:**
→ [CONTRIBUTING](../CONTRIBUTING.md) → Reporting bugs
```

3. Shorten `QUICKSTART.md` to <50 lines (link out to detailed docs).

4. Reorganize `CHEATSHEET.md` by workflow (project creation, AI modes, scans, OSS, interview).

5. Update `README.md` to link to `docs/TOC.md` prominently.

**Test Plan:**
1. Open `docs/TOC.md`
2. Verify all links work
3. Follow "I'm new" path in `docs/WHERE_TO_START.md`
4. Verify docs are findable

**Risk:** Low — documentation only

**Size:** Medium (~300 LOC across multiple docs)

---

## GROUP B: High Priority (Required for v3.0.0)

### B1: Create .cursorrules (markdown format) for Cursor IDE

**Rationale:** `.cursor/rules.json` exists but Cursor uses `.cursorrules` (markdown). Need standard format.

**Affected Files:**
- **New:** `.cursorrules` (markdown format)
- **Keep:** `.cursor/rules.json` (for backward compatibility)
- **New:** `docs/CURSOR_GUIDE.md`

**Implementation:**

1. Create `.cursorrules`:
```markdown
# AI Toolkit - Cursor Rules

**Version:** 3.0.0
**Mode:** [INJECTED BY bin/ai-mode]

---

## Developer Control

**Rule:** AI proposes, human approves.

- DO NOT implement without explicit approval
- DO show diffs before applying
- DO suggest verification commands (don't auto-run)
- WAIT for "Approve: A1, B3..." before proceeding

---

## Small Changes

**Rule:** Max 200 LOC or ~20 minutes of work per step.

- DO break large features into small items (A1, A2, A3...)
- DO commit incrementally
- DO provide clear rationale for each item

---

## Test Coverage

**Rule:** New functionality requires tests.

- DO write RSpec tests for Rails code
- DO write Jest/Vitest tests for React code
- DO test edge cases (nil, empty, invalid)
- DO verify tests pass before committing

---

## Protected Files

**Rule:** Never modify without explicit approval.

Protected:
- `config/job_wizard/*.yml`
- `.env*` files
- `config/database.yml`
- Deploy configs

---

## Truth Data

**Rule:** No fabricated credentials, skills, or experience.

- DO use realistic test data (Faker gem)
- DO NOT invent user credentials
- DO NOT fabricate project history

---

## Quality Gates

**Rule:** RuboCop/ESLint must pass.

Safe to suggest:
- `bundle exec rubocop -A`
- `bundle exec rspec`
- `npm run lint:fix`
- `just test`

Never auto-run:
- `git push`
- `rails db:migrate` (production)
- `bundle install`
- `rails destroy`

---

## Workflow Sequence

1. **PLANNER** creates plan with questions
2. Human answers
3. **ENGINEER** implements ONE step
4. **CRITIC** reviews against checklist
5. Human approves/revises
6. Repeat

---

## Diagnostic Mode

**Rule:** Use diagnostic.prompt when stuck.

Triggers:
- Repeated bug fix attempts
- Same error after multiple tries
- Unclear root cause

Process: TRACE → PROVE → CLASSIFY → PROPOSE (no edits)

---

## Project Context

Repository: [INJECTED]
Stack: [INJECTED]
Conventions: [INJECTED]

---

## Commands

- `dev plan "Feature"` — Create plan
- `dev scans` — Security/quality scans
- `dev mode [driver|approval|autopilot]` — Switch AI mode
- `just test` — Run tests
- `just lint-fix` — Auto-fix linting
- `scan_here` — Quick security check

---

## Current Mode

[INJECTED BY bin/ai-mode]

See `ai/mode-*.prompt` for mode-specific guidelines.
```

2. Update `bin/ai-mode` to inject mode into `.cursorrules`:
```bash
# After creating ai/mode.txt
if [[ -f .cursorrules ]]; then
  # Inject mode into .cursorrules
  sed -i.bak "s/\*\*Mode:\*\* \[INJECTED BY bin\/ai-mode\]/\*\*Mode:\*\* $mode/g" .cursorrules
  rm .cursorrules.bak
fi
```

3. Create `docs/CURSOR_GUIDE.md`:
```markdown
# Cursor IDE Guide

This guide explains how to use AI Toolkit with Cursor IDE.

---

## Setup

### Step 1: Install Cursor
Download from [cursor.sh](https://cursor.sh)

### Step 2: Setup API Key
See [CLAUDE_SETUP](CLAUDE_SETUP.md) for BYOK instructions.

### Step 3: Verify `.cursorrules`
AI Toolkit projects include `.cursorrules` (workflow rules).

Check:
```bash
cat .cursorrules  # Should show AI Toolkit rules
```

If missing:
```bash
dev bootstrap  # Re-sync templates
```

---

## AI Modes

### DRIVER MODE (You Write, AI Reviews)

**When to use:**
- Learning new codebase
- Tight control needed
- Code walkthroughs

**How to activate:**
```bash
dev mode driver
```

**Usage:**
1. Write code
2. Ask AI: "Review this diff"
3. AI provides checklist (BLOCKERS, NITS, RISKS)
4. Apply feedback
5. Repeat

### APPROVAL MODE (AI Plans, You Approve)

**When to use:**
- Feature development
- Refactoring
- Bug fixes

**How to activate:**
```bash
dev mode approval
```

**Usage:**
1. Create plan: `dev plan "Feature Name"`
2. AI creates plan with labeled items (A1, A2, B1, B2...)
3. Reply: "Approve: A1, B3" to select items
4. AI implements only approved items
5. AI shows diffs, suggests verification
6. Apply changes, run verification
7. Repeat for next approved item

**Example:**
```
You: "Add user authentication"

AI:
## GROUP A: Core Auth
- **A1:** Add Devise gem (Rationale: industry standard, Risk: low, Size: S)
- **A2:** Generate User model (Rationale: ..., Risk: low, Size: S)
- **A3:** Add login/logout routes (Rationale: ..., Risk: low, Size: S)

## GROUP B: Testing
- **B1:** User model specs (Rationale: ..., Risk: low, Size: M)
- **B2:** Auth integration tests (Rationale: ..., Risk: med, Size: M)

Which items to implement?

You: "Approve: A1, A2, B1"

AI: Implementing A1...
[Shows diff for Gemfile]
Verification: `bundle install && bundle exec rspec`
```

### AUTOPILOT MODE (AI Implements End-to-End)

**When to use:**
- Prototypes
- Repetitive tasks
- Well-defined features

**How to activate:**
```bash
dev mode autopilot
```

**Usage:**
1. Describe task: "Add user authentication with Devise"
2. AI implements completely (small commits)
3. AI reports what was done
4. Review changes: `git diff`
5. Run verification: `just test`
6. Commit if satisfied

**When AI asks:**
- Ambiguous requirements
- Breaking changes
- Missing context

---

## Workflows

### Feature Development (APPROVAL MODE)

```bash
# 1. Set mode
dev mode approval

# 2. Create plan
dev plan "User can upload profile photo"

# 3. AI creates plan (A1, A2, B1...)
# Reply: "Approve: A1, A2"

# 4. AI implements A1
# Review diff, run verification

# 5. Commit
git add .
git commit -m "feat: add photo upload model"

# 6. Continue with next item
# Reply: "Approve: A3"
```

### Bug Fix (AUTOPILOT MODE)

```bash
# 1. Set mode
dev mode autopilot

# 2. Describe bug
# AI: "User login fails with blank email"

# 3. AI implements fix + tests
# 4. Review changes
git diff

# 5. Run tests
just test

# 6. Commit
git commit -am "fix: validate email presence on login"
```

### Code Review (DRIVER MODE)

```bash
# 1. Set mode
dev mode driver

# 2. Write code
# (make changes in editor)

# 3. Ask for review
# AI: "Review this diff"

# 4. AI provides feedback
# BLOCKERS: Missing null check
# NITS: Consider extracting method
# RISKS: Migration needs backfill

# 5. Apply feedback
# (make changes in editor)

# 6. Commit
git commit -am "feat: add user profile"
```

---

## Tips & Tricks

### Use Cursor Chat (Cmd+L)

**Quick tasks:**
- "Review this file"
- "Explain this function"
- "Generate test for this method"

### Use Cursor Composer (Cmd+K)

**Code generation:**
- "Add validation to User model"
- "Extract this into a service"
- "Rename this method across project"

### Use AI Toolkit Commands

**Planning:**
```bash
dev plan "Feature"           # Creates ai/plans/*.md
```

**Scans:**
```bash
dev scans                    # Run all security/quality scans
scan_here                    # Quick scan (same as above)
```

**Mode switching:**
```bash
dev mode                     # Show current mode
dev mode approval            # Switch to approval mode
```

### Diagnostic Recovery

**When AI is stuck:**
1. Stop current task
2. Run: `ai_diagnose`
3. Opens `prompts/diagnostic.prompt` in context
4. AI uses TRACE → PROVE → CLASSIFY → PROPOSE
5. No edits until diagnosis complete

---

## Troubleshooting

### ".cursorrules not loaded"

**Cause:** Cursor doesn't recognize file.

**Fix:**
1. Restart Cursor
2. Open project folder (not file)
3. Check Cursor settings: **Enable .cursorrules**

### "AI ignores mode"

**Cause:** Mode not injected into `.cursorrules`.

**Fix:**
```bash
dev mode approval  # Re-inject mode
```

### "AI makes large changes"

**Cause:** Not following 200 LOC limit.

**Fix:**
1. Stop AI
2. Reply: "Too large. Break into smaller steps (A1, A2, A3)"
3. AI re-plans with smaller items

### "AI auto-runs dangerous commands"

**Cause:** Not following never-auto-run rule.

**Fix:**
1. Stop AI
2. Reply: "Never auto-run git push, bundle install, or migrations"
3. AI will only suggest commands

---

## Advanced

### Custom Mode Templates

Create custom mode in `ai/modes/`:
```markdown
# MY CUSTOM MODE

Rules:
- ...

Workflow:
1. ...
```

Activate:
```bash
dev mode custom  # (requires bin/ai-mode enhancement)
```

### Per-Project Overrides

Edit `.cursorrules` directly:
```markdown
## Project-Specific Rules

- DO use Sidekiq for background jobs
- DO follow service object pattern
- DO NOT use callbacks in models
```

### Integration with Overcommit

Pre-commit hooks run automatically:
- RuboCop (required)
- RSpec (optional)

Pre-push hooks:
- Brakeman (security)
- BundleAudit (gem vulnerabilities)

---

## Next Steps

1. ✅ Setup Cursor + API key
2. 📖 Set AI mode: `dev mode approval`
3. 🚀 Create first plan: `dev plan "Feature"`
4. 🛠️ Follow WORKFLOWS for recipes
```

**Test Plan:**
1. Create test project
2. Run `dev bootstrap`
3. Verify `.cursorrules` created
4. Open in Cursor
5. Verify Cursor loads rules (check settings)
6. Run `dev mode approval`
7. Verify `.cursorrules` updated with mode

**Risk:** Low — new file, doesn't break existing workflows

**Size:** Medium (~200 LOC across multiple files)

---

### B2: Add shellcheck CI workflow

**Rationale:** Shellcheck tests exist but not CI-integrated. Need automation.

**Affected Files:**
- **New:** `.github/workflows/test.yml`

**Implementation:**

1. Create `.github/workflows/test.yml`:
```yaml
name: Test

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install shellcheck
        run: sudo apt-get install -y shellcheck

      - name: Run unit tests
        run: bash test/run_all_tests.sh

      - name: Run shellcheck
        run: bash bin/test_shell
```

**Test Plan:**
1. Create PR with syntax error in `bin/dev`
2. Verify CI fails
3. Fix error
4. Verify CI passes

**Risk:** Low — new file, doesn't affect existing workflows

**Size:** Small (~30 LOC)

---

### B3: Add AI_GUARDRAILS.md (privacy, truth-only, local-first)

**Rationale:** No explicit privacy/safety documentation.

**Affected Files:**
- **New:** `docs/AI_GUARDRAILS.md`
- **Modified:** `docs/TOC.md` (add link)

**Implementation:**

1. Create `docs/AI_GUARDRAILS.md`:
```markdown
# AI Guardrails

AI Toolkit enforces strict safety and privacy guardrails for AI-assisted development.

---

## Privacy Guardrails

### 🔒 Local-Only Mode

**Principle:** All code and data stays on your machine by default.

**Enforcement:**
- No cloud services required (SQLite, not hosted DB)
- No telemetry or usage tracking
- No automatic code sharing
- BYOK (Bring Your Own Key) only

**Exceptions (explicit user action):**
- Using `dev oss init` to fork public repo
- Using `gh` CLI to create PR
- Using cloud LLM API (with user-provided key)

### 🚫 No Secrets Leakage

**Principle:** Never commit or expose API keys, passwords, or credentials.

**Enforcement:**
- `.gitignore` excludes `.env*`
- `dev preflight` checks for leaked secrets
- Gitleaks scanning in interview-sandbox
- Protected file list in `.cursorrules`

**Verification:**
```bash
dev preflight  # Run before committing
```

### 🔐 BYOK (Bring Your Own Key)

**Principle:** You control your API keys, not the toolkit.

**Enforcement:**
- No hardcoded keys in codebase
- Keys stored in `~/.zshrc` or IDE settings (not repo)
- Provider abstraction (Anthropic, OpenAI)
- Preflight checks verify no keys in tracked files

**Setup:**
See [CLAUDE_SETUP](CLAUDE_SETUP.md) for BYOK instructions.

---

## Truth-Only Policy

### ❌ No Fabricated Data

**Principle:** AI must not invent credentials, skills, or experience.

**Applies to:**
- User profiles (no fake job history)
- Resumes (no invented companies)
- Cover letters (no fabricated achievements)
- Project context (no non-existent features)

**Enforcement:**
- `.cursorrules` documents rule
- `ai/constraints.md` specifies protected files
- Human review required for user-facing content

**Exceptions:**
- Test data (Faker gem) for development
- Example data in documentation
- Placeholder text with clear markers ("TODO", "[EXAMPLE]")

### ✅ Realistic Test Data

**Use Faker gem:**
```ruby
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end
end
```

**NOT this:**
```ruby
# ❌ BAD: Looks like real person
User.create(name: "John Smith", email: "jsmith@company.com")

# ✅ GOOD: Clearly fake
User.create(name: Faker::Name.name, email: Faker::Internet.email)
```

---

## Safety Guardrails

### 🛑 Never Auto-Run Dangerous Commands

**Principle:** AI suggests, human executes risky commands.

**Never auto-run:**
- `git push` (could expose secrets)
- `rails db:migrate` in production (data risk)
- `bundle install` (dependency changes)
- `rails destroy` (irreversible)
- `rm -rf` (data loss)
- `sudo` commands (privilege escalation)

**Safe to suggest:**
- `bundle exec rubocop -A`
- `bundle exec rspec`
- `rails db:migrate` (development only)
- `just test`
- `git status/diff`

**Enforcement:**
- `.cursorrules` documents never-auto-run list
- AI modes (driver, approval, autopilot) respect rules
- Human must copy-paste commands to execute

### 🔒 Protected Files

**Principle:** Certain files require explicit approval before modification.

**Protected:**
- `config/job_wizard/*.yml` (user profile, experience, rules)
- `.env*` files (secrets)
- `config/database.yml` (data access)
- Deploy configs (production risk)
- `.git/` directory (version control)

**Enforcement:**
- `.cursorrules` lists protected files
- `ai/constraints.md` documents rationale
- AI must ask before modifying

**Override:**
Reply: "Approved: modify config/job_wizard/profile.yml"

---

## Quality Guardrails

### ✅ Test Coverage Required

**Principle:** New functionality must have tests.

**Enforcement:**
- `.cursorrules` requires tests
- AI roles (ENGINEER) include tests in implementation
- Pre-commit hooks optionally run RSpec

**Verification:**
```bash
just test         # Run all tests
just test-cov     # Run with coverage report
```

### ✅ Linting Must Pass

**Principle:** RuboCop/ESLint must pass before committing.

**Enforcement:**
- `.rubocop.yml` with strict rules
- Pre-commit hook runs RuboCop (required)
- CI workflow runs linting

**Auto-fix:**
```bash
just lint-fix     # Auto-fix RuboCop issues
```

### ✅ Security Scanning

**Principle:** Scan for vulnerabilities before committing.

**Enforcement:**
- Pre-push hook runs Brakeman + BundleAudit
- `dev scans` runs full security suite
- Interview-sandbox auto-scans candidate code

**Manual scan:**
```bash
dev scans         # Run all scans
scan_here         # Same as above
```

---

## Rollback Guardrails

### 🔄 Small Commits

**Principle:** Max 200 LOC per commit (~20 min work).

**Rationale:**
- Easy to review
- Easy to rollback
- Clear intent

**Enforcement:**
- `.cursorrules` documents limit
- AI modes break large features into small steps
- CRITIC role verifies size before approval

### 🔄 Reversible Migrations

**Principle:** Database migrations must be reversible.

**Enforcement:**
- `prompts/migration.prompt` guides safe migrations
- Always define `up` and `down` methods
- Test rollback: `rails db:rollback`

**Example:**
```ruby
class AddEmailToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :email, :string, null: false, default: ""
    add_index :users, :email, unique: true
  end
end

# Reversible: change method auto-generates down
```

---

## Cost Guardrails

### 💰 Token Usage Awareness

**Principle:** Be mindful of LLM API costs.

**Best practices:**
- Use APPROVAL mode (review plans before implementing)
- Break large features into small steps
- Use diagnostic.prompt to avoid bug loops
- Prefer local tools (grep, rubocop) over AI for simple tasks

**Cost-saving mode:**
Activate `cost-guardian` mode (see `prompts/modes.prompt`):
- Smaller context windows
- Explicit approval for long responses
- Token count tracking

### 💰 Recommended Models

**Balance cost vs quality:**

| Model | Cost | Best For |
|-------|------|----------|
| `claude-3-5-haiku-20241022` | $ | Quick iterations, small fixes |
| `claude-sonnet-4-5-20250929` | $$ | **Coding** (recommended) |
| `claude-opus-4-20250514` | $$$ | Complex reasoning, architecture |

**Setup:**
See [CLAUDE_SETUP](CLAUDE_SETUP.md) for model selection.

---

## Enforcement Summary

| Guardrail | Enforcement | Override |
|-----------|-------------|----------|
| **Local-only** | Default (SQLite, no cloud) | User explicitly uses cloud service |
| **No secrets** | Preflight checks + Gitleaks | N/A (hard rule) |
| **BYOK** | No hardcoded keys | N/A (hard rule) |
| **Truth-only** | `.cursorrules` + human review | N/A (hard rule) |
| **Never auto-run** | `.cursorrules` + AI modes | N/A (hard rule) |
| **Protected files** | `.cursorrules` | Reply: "Approved: modify X" |
| **Test coverage** | `.cursorrules` + pre-commit (opt) | Skip for prototypes |
| **Linting** | Pre-commit (required) | `git commit --no-verify` |
| **Security scans** | Pre-push (required) | `git push --no-verify` |
| **Small commits** | `.cursorrules` + CRITIC | Override for urgent fixes |

---

## Verification Checklist

Before committing:

- [ ] Run `dev preflight` (checks secrets, gitignore)
- [ ] Run `just test` (verify tests pass)
- [ ] Run `just lint` (verify RuboCop passes)
- [ ] Run `git status` (verify no unintended files)
- [ ] Run `git diff` (review changes)
- [ ] Verify commit message follows conventions

Before pushing:

- [ ] Run `dev scans` (security + quality)
- [ ] Verify tests pass in CI
- [ ] Review PR diff
- [ ] Verify no protected files modified without approval

---

## Reporting Violations

If AI violates guardrails:

1. **Stop immediately:** Reply "Stop, this violates guardrails"
2. **Document:** Note which guardrail (privacy, truth-only, safety)
3. **Report:** Open issue in toolkit repo
4. **Fix:** Rollback changes, re-plan with guardrails enforced

---

## Next Steps

1. ✅ Review guardrails (this doc)
2. 📖 Setup API key with BYOK: [CLAUDE_SETUP](CLAUDE_SETUP.md)
3. 🔒 Run preflight: `dev preflight`
4. 🚀 Start building with safety: `dev mode approval`
```

2. Update `docs/TOC.md` to link to `AI_GUARDRAILS.md`.

**Test Plan:**
1. Read `docs/AI_GUARDRAILS.md`
2. Verify all links work
3. Verify examples are clear

**Risk:** Low — documentation only

**Size:** Medium (~300 LOC)

---

### B4: Add preflight to bootstrap workflow

**Rationale:** Preflight checks exist but not automatically run. Need integration into `dev bootstrap`.

**Affected Files:**
- **Modified:** `bin/dev` (already done in A3)

**Implementation:**

Already implemented in A3:
```bash
bootstrap)
  run_preflight || echo "⚠️  Preflight warnings (non-blocking)"
  ai_bootstrap_repo
  ;;
```

**Test Plan:**
1. Create test repo with secrets in tracked file
2. Run `dev bootstrap`
3. Verify preflight warns but continues
4. Fix issue
5. Run `dev bootstrap` again
6. Verify passes

**Risk:** Low — non-blocking warnings

**Size:** Small (already done)

---

### B5: Update README with TOC link

**Rationale:** README is long. Need prominent link to TOC for navigation.

**Affected Files:**
- **Modified:** `README.md`

**Implementation:**

Add near top of `README.md`:
```markdown
# AI Development Toolkit

**Version:** 3.0.0

Opinionated Rails + React development toolkit with AI-assisted workflows.

📚 **[Full Documentation Index →](docs/TOC.md)**

## Quick Links

- [Getting Started →](QUICKSTART.md)
- [Setup Claude API →](docs/CLAUDE_SETUP.md)
- [Cursor Guide →](docs/CURSOR_GUIDE.md)
- [Command Reference →](CHEATSHEET.md)
- [Workflows →](WORKFLOWS.md)

---

## Overview

[Existing README content...]
```

**Test Plan:**
1. Open `README.md`
2. Verify TOC link prominent
3. Click link
4. Verify navigates to `docs/TOC.md`

**Risk:** Low — cosmetic change

**Size:** Small (~10 LOC)

---

## GROUP C: Medium Priority (Nice-to-Have for v3.0.0)

### C1: Complete React integration (eslintrc.cjs, testing setup)

**Rationale:** React templates exist but incomplete. No ESLint config template, no testing setup.

**Affected Files:**
- **New:** `templates/react/.eslintrc.cjs`
- **New:** `templates/react/vitest.config.js`
- **New:** `docs/REACT_SETUP.md`
- **Modified:** `bin/dev` (`new rails-react` command)

**Implementation:**

1. Create `templates/react/.eslintrc.cjs`:
```javascript
module.exports = {
  root: true,
  env: { browser: true, es2020: true },
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:react-hooks/recommended',
    'plugin:react/recommended',
  ],
  ignorePatterns: ['dist', '.eslintrc.cjs'],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
    ecmaFeatures: { jsx: true },
  },
  plugins: ['react-refresh', '@typescript-eslint', 'react'],
  rules: {
    'react-refresh/only-export-components': [
      'warn',
      { allowConstantExport: true },
    ],
    'react/react-in-jsx-scope': 'off',
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
  },
  settings: {
    react: { version: '18.2' },
  },
};
```

2. Create `templates/react/vitest.config.js`:
```javascript
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      exclude: ['node_modules/', 'src/test/'],
    },
  },
});
```

3. Create `docs/REACT_SETUP.md`:
```markdown
# React Setup Guide

AI Toolkit supports React apps (Vite + TypeScript).

## Create New React App

```bash
dev new rails-react MyApp
cd MyApp/client
```

## Project Structure

```
MyApp/
├── app/               # Rails API
│   └── controllers/
├── client/            # React frontend
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── test/
│   │   └── App.tsx
│   ├── .eslintrc.cjs
│   ├── vitest.config.js
│   └── package.json
└── README.md
```

## Development

**Start Rails API:**
```bash
cd MyApp
rails server -p 3000
```

**Start React dev server:**
```bash
cd MyApp/client
npm run dev  # Starts on port 5173
```

**API calls:**
```typescript
// client/src/api/users.ts
export async function fetchUsers() {
  const response = await fetch('http://localhost:3000/api/users');
  return response.json();
}
```

## Testing

**Run tests:**
```bash
cd client
npm run test
```

**Coverage:**
```bash
npm run test:coverage
```

**Example test:**
```typescript
// src/components/Button.test.tsx
import { render, screen } from '@testing-library/react';
import { Button } from './Button';

test('renders button with text', () => {
  render(<Button>Click me</Button>);
  expect(screen.getByText('Click me')).toBeInTheDocument();
});
```

## Linting

**Run ESLint:**
```bash
npm run lint
```

**Auto-fix:**
```bash
npm run lint:fix
```

## Pre-commit Hooks

Husky pre-commit hook (`.husky/pre-commit`):
```bash
#!/bin/sh
cd client && npm run lint && npm run test
```

## Next Steps

1. Setup API key: [CLAUDE_SETUP](CLAUDE_SETUP.md)
2. Set AI mode: `dev mode approval`
3. Build features: `dev plan "React component"`
```

4. Update `bin/dev` (`new rails-react` command) to copy React templates.

**Test Plan:**
1. Run `dev new rails-react TestApp`
2. Verify `client/.eslintrc.cjs` copied
3. Verify `client/vitest.config.js` copied
4. Run `cd client && npm run lint`
5. Verify passes

**Risk:** Low — new functionality, doesn't break existing

**Size:** Medium (~200 LOC across multiple files)

---

### C2: Add JobWizard architecture docs

**Rationale:** JobWizard templates exist but architecture not explained.

**Affected Files:**
- **New:** `docs/JOBWIZARD.md`
- **Modified:** `templates/jobwizard/README_APPEND.md` (link to docs)

**Implementation:**

1. Create `docs/JOBWIZARD.md`:
```markdown
# JobWizard Architecture

JobWizard is a job search tracking app with AI-powered job description analysis.

## Overview

**Features:**
- Track job applications (applied, interviewing, rejected, offer)
- Store user profile (skills, experience, preferences)
- Analyze job descriptions against profile
- Generate customized cover letters
- Track interview stages

## Data Model

```
User
├── Profile (1:1)
│   ├── name, email, phone
│   ├── summary (bio)
│   └── skills (array)
├── Experiences (1:N)
│   ├── company, title, start_date, end_date
│   └── description
├── Jobs (1:N)
│   ├── company, title, url
│   ├── description (raw HTML)
│   ├── description_clean (sanitized)
│   ├── match_score (0-100)
│   └── status (applied, interviewing, rejected, offer)
└── Applications (1:N)
    ├── job_id
    ├── cover_letter
    ├── status
    └── notes
```

## Configuration Files

### `config/job_wizard/profile.yml`

User profile structure:
```yaml
profile:
  name: string
  email: string
  phone: string
  summary: text
  skills: array<string>
  preferences:
    location: array<string>
    remote: boolean
    salary_min: integer
    salary_max: integer
```

**Protected:** Requires explicit approval to modify.

### `config/job_wizard/experience.yml`

Work experience structure:
```yaml
experience:
  company: string
  title: string
  start_date: date
  end_date: date (nullable)
  description: text
  achievements: array<string>
```

### `config/job_wizard/rules.yml`

Job matching rules:
```yaml
rules:
  required_skills:
    weight: 40
    match_threshold: 0.7
  experience_years:
    weight: 30
    match_threshold: 0.8
  location:
    weight: 20
    match_threshold: 1.0
  salary:
    weight: 10
    match_threshold: 0.9
```

## Job Description Cleaning

**Problem:** Job descriptions often contain HTML, tracking pixels, formatting.

**Solution:** `html-cleanup` AI mode (see `prompts/modes.prompt`).

**Process:**
1. User pastes raw HTML job description
2. AI mode activated: `dev mode html-cleanup`
3. AI extracts: company, title, location, salary, requirements, description
4. AI removes: HTML tags, tracking pixels, excessive whitespace
5. Output: Clean markdown stored in `Job.description_clean`

**Example:**
```ruby
# app/services/job_description_cleaner.rb
class JobDescriptionCleaner
  def self.clean(raw_html)
    # Call AI with html-cleanup prompt
    # Returns structured data
  end
end
```

## Matching Algorithm

**Scores job against user profile (0-100):**

1. **Required Skills Match (40%):**
   - Extract skills from job description
   - Compare with user profile skills
   - Score = (matched skills / required skills) * 40

2. **Experience Match (30%):**
   - Extract years experience required
   - Compare with user experience
   - Score = min(user_years / required_years, 1.0) * 30

3. **Location Match (20%):**
   - Check location preferences
   - Remote = 20 pts
   - Preferred city = 20 pts
   - Otherwise = 0 pts

4. **Salary Match (10%):**
   - Check if salary in user range
   - In range = 10 pts
   - Below min = 0 pts

**Example:**
```ruby
# app/services/job_matcher.rb
class JobMatcher
  def initialize(job, profile)
    @job = job
    @profile = profile
  end

  def match_score
    skills_score + experience_score + location_score + salary_score
  end

  private

  def skills_score
    # ...
  end
end
```

## AI Modes for JobWizard

### `html-cleanup` Mode

**Purpose:** Extract clean data from messy job descriptions.

**Usage:**
```bash
dev mode html-cleanup
# Paste raw HTML
# AI extracts structured data
```

### `plan-approve` Mode

**Purpose:** Add new features (e.g., interview tracker).

**Usage:**
```bash
dev mode approval
dev plan "Add interview stage tracking"
# AI creates plan
# Reply: "Approve: A1, A2"
```

## Deployment

**Render.com (recommended):**
```bash
# 1. Create Render account
# 2. New Web Service → GitHub repo
# 3. Build: bundle install && rails db:migrate
# 4. Start: bundle exec rails server -p $PORT
# 5. Environment: Set RAILS_ENV=production, SECRET_KEY_BASE=...
```

**Environment variables:**
```
RAILS_ENV=production
SECRET_KEY_BASE=<generated>
DATABASE_URL=postgres://...
ANTHROPIC_API_KEY=sk-ant-... (for AI features)
```

## Next Steps

1. Create JobWizard app: `dev new jobwizard MyJobApp`
2. Setup API key: [CLAUDE_SETUP](docs/CLAUDE_SETUP.md)
3. Set AI mode: `dev mode html-cleanup` or `dev mode approval`
4. Start tracking jobs!
```

2. Update `templates/jobwizard/README_APPEND.md` to link to `docs/JOBWIZARD.md`.

**Test Plan:**
1. Read `docs/JOBWIZARD.md`
2. Verify architecture clear
3. Verify examples work

**Risk:** Low — documentation only

**Size:** Medium (~200 LOC)

---

### C3: Document OSS harvest output format

**Rationale:** `oss/harvest.sh` is complex but output format unclear.

**Affected Files:**
- **New:** `docs/OSS_HARVEST.md`
- **Modified:** `oss/harvest.sh` (add header comment)

**Implementation:**

1. Create `docs/OSS_HARVEST.md`:
```markdown
# OSS Harvest Tool

The `dev oss init` command harvests context from open source repositories to help you contribute effectively.

## What It Does

**Extracts:**
1. Git origin URL
2. Default branch (main, master, develop)
3. README (first 400 lines)
4. CONTRIBUTING.md
5. CODE_OF_CONDUCT.md
6. Language/tooling (Ruby, Node, Python, Go, Rust)
7. Version files (.ruby-version, .node-version)
8. Linting configs (RuboCop, ESLint, .editorconfig)
9. CI workflows (GitHub Actions, CircleCI)
10. DCO/CLA requirements
11. Commit message conventions

**Output:** `ai/oss/context.md` (reference doc for AI)

## Usage

### Initialize OSS Context

```bash
dev oss init owner/repo
```

**Example:**
```bash
dev oss init rails/rails
cd rails
cat ai/oss/context.md  # Review harvested context
```

### Re-harvest (after repo changes)

```bash
dev oss harvest
```

## Output Format

**File:** `ai/oss/context.md`

**Structure:**
```markdown
# OSS Context: owner/repo

**Harvested:** YYYY-MM-DD HH:MM:SS

---

## Repository Info

- **URL:** https://github.com/owner/repo
- **Default Branch:** main
- **Language:** Ruby (3.3.0)
- **Tooling:** RuboCop, RSpec, GitHub Actions

---

## README (first 400 lines)

[README content...]

---

## CONTRIBUTING

[CONTRIBUTING.md content...]

---

## CODE_OF_CONDUCT

[CODE_OF_CONDUCT.md content...]

---

## Linting Configuration

**RuboCop:** .rubocop.yml present
**ESLint:** Not found
**EditorConfig:** .editorconfig present

---

## CI/CD

**GitHub Actions:**
- .github/workflows/ci.yml (test suite)
- .github/workflows/lint.yml (linting)

**CircleCI:** Not found

---

## Contribution Requirements

**DCO (Developer Certificate of Origin):** Required
  - Sign commits: `git commit -s`

**CLA (Contributor License Agreement):** Not required

**Commit Message Convention:**
- Format: `type(scope): subject`
- Types: feat, fix, docs, style, refactor, test, chore
- Example: `feat(auth): add two-factor authentication`

---

## Version Requirements

- Ruby: 3.3.0 (.ruby-version)
- Bundler: latest
- Node: Not used

---

## Next Steps

1. Read CONTRIBUTING (above)
2. Find issue: `dev oss goodfirst owner/repo`
3. Create plan: `dev oss plan "Fix issue #123"`
4. Implement: Use PLANNER/ENGINEER/CRITIC workflow
5. Prepare PR: `dev oss pr`
```

## How It Works

**Script:** `oss/harvest.sh` (80 lines)

**Process:**
1. Clone repo (if not exists) or pull latest
2. Detect default branch: `git symbolic-ref refs/remotes/origin/HEAD`
3. Extract README: `head -n 400 README.md`
4. Find CONTRIBUTING: Search root, docs/, .github/
5. Find CODE_OF_CONDUCT: Search root, docs/, .github/
6. Detect language:
   - Ruby: .ruby-version, Gemfile
   - Node: .node-version, package.json
   - Python: .python-version, requirements.txt
   - Go: go.mod
   - Rust: Cargo.toml
7. Find linting configs: .rubocop.yml, .eslintrc*, .editorconfig
8. Find CI: .github/workflows/, .circleci/
9. Detect DCO: Search CONTRIBUTING for "sign-off" or "DCO"
10. Detect CLA: Search CONTRIBUTING for "CLA" or "Contributor License"
11. Infer commit convention: Check recent commits for patterns
12. Write to `ai/oss/context.md`

**Example output:**
```bash
$ dev oss init rails/rails
🔍 Harvesting OSS context for rails/rails...
✅ Cloned to ~/oss/rails
✅ Default branch: main
✅ README found (12000 lines, truncated to 400)
✅ CONTRIBUTING found
✅ CODE_OF_CONDUCT found
✅ Language: Ruby (3.3.0)
✅ RuboCop config found
✅ GitHub Actions found (3 workflows)
✅ DCO required (sign commits)
✅ Commit convention: type(scope): subject

📄 Context saved to: ai/oss/context.md

Next steps:
  cd rails
  cat ai/oss/context.md       # Review context
  dev oss goodfirst rails/rails  # Find good first issues
```

## AI Usage

**Context injection:**
When using AI for OSS contributions, include `ai/oss/context.md` in context:

```
You: "I want to contribute to rails/rails. Review ai/oss/context.md."

AI: [Reads context]
"This project uses:
- Ruby 3.3.0
- RuboCop for linting
- RSpec for testing
- DCO required (sign commits with git commit -s)
- Commit convention: type(scope): subject

Ready to find an issue?"
```

## Customization

**Edit harvest script:**
```bash
vim ~/.ai-toolkit/oss/harvest.sh
```

**Add custom checks:**
```bash
# Example: Check for Docker support
if [[ -f Dockerfile ]]; then
  echo "✅ Dockerfile found"
fi
```

## Troubleshooting

### "Failed to detect default branch"

**Cause:** Non-standard default branch name.

**Fix:**
```bash
cd repo
git branch -r  # List remote branches
# Manually set in ai/oss/context.md
```

### "README not found"

**Cause:** Non-standard README location (README.rst, docs/README.md).

**Fix:**
```bash
# Edit harvest.sh to check alternate locations
if [[ -f README.rst ]]; then
  README_FILE="README.rst"
fi
```

## Next Steps

1. Initialize OSS context: `dev oss init owner/repo`
2. Review context: `cat ai/oss/context.md`
3. Find issue: `dev oss goodfirst owner/repo`
4. Create plan: `dev oss plan "Fix issue #123"`
```

2. Add header comment to `oss/harvest.sh`:
```bash
#!/usr/bin/env bash
# OSS Context Harvester
# Extracts repository context for AI-assisted contributions
# Output: ai/oss/context.md
# See docs/OSS_HARVEST.md for details
```

**Test Plan:**
1. Read `docs/OSS_HARVEST.md`
2. Verify examples clear
3. Verify output format documented

**Risk:** Low — documentation only

**Size:** Medium (~200 LOC)

---

### C4: Update RuboCop template (require → plugins)

**Rationale:** `templates/rails/.rubocop.yml` uses deprecated `require:` syntax. Modern RuboCop prefers plugin managers, but `require:` still works.

**Affected Files:**
- **Modified:** `templates/rails/.rubocop.yml`

**Implementation:**

Update `templates/rails/.rubocop.yml`:
```yaml
AllCops:
  NewCops: enable
  TargetRubyVersion: 3.3  # Dynamically set by template
  Exclude:
    - db/migrate/*
    - db/schema.rb
    - node_modules/**/*
    - vendor/**/*

require:
  - rubocop-rails
  - rubocop-rspec

# (rest of config unchanged)
```

**Note:** `require:` still works in RuboCop 1.x. Migration to plugin managers (e.g., `rubocop-rails_config`) is optional and would require additional setup. For simplicity, keep `require:` for now.

**Test Plan:**
1. Create new Rails app: `dev new rails TestApp`
2. Run `bundle exec rubocop`
3. Verify no deprecation warnings

**Risk:** Low — cosmetic change, still functional

**Size:** Small (~5 LOC)

---

## Summary

### GROUP A (Critical)
- **A1:** Claude-specific prompts & modes scaffolding (bin/ai-mode)
- **A2:** Provider adapters (providers/anthropic.rb + openai.rb)
- **A3:** BYOK docs + safety (docs/CLAUDE_SETUP.md + bin/preflight)
- **A4:** Refactor "dev" CLI into composable functions + shellcheck
- **A5:** Doc consolidation (docs/TOC.md + WHERE_TO_START.md)

### GROUP B (High Priority)
- **B1:** Create .cursorrules + docs/CURSOR_GUIDE.md
- **B2:** Add shellcheck CI workflow (.github/workflows/test.yml)
- **B3:** Add docs/AI_GUARDRAILS.md
- **B4:** Add preflight to bootstrap workflow (already in A3)
- **B5:** Update README with TOC link

### GROUP C (Medium Priority)
- **C1:** Complete React integration (eslintrc.cjs + vitest + docs)
- **C2:** Add JobWizard architecture docs
- **C3:** Document OSS harvest output format
- **C4:** Update RuboCop template (cosmetic)

---

## Top 5 High-Impact Items

1. **A1: Mode switching (bin/ai-mode)** — Enables DRIVER/APPROVAL/AUTOPILOT workflows
2. **A3: BYOK + preflight** — Fixes critical security/setup gap
3. **A5: Doc consolidation (TOC)** — Makes toolkit usable for new users
4. **B1: .cursorrules + CURSOR_GUIDE** — Fixes Cursor/Claude Code integration
5. **B3: AI_GUARDRAILS** — Documents critical safety/privacy policies

---

## Rollout Plan

### Phase 1: Critical (Week 1)
- Implement GROUP A (A1-A5)
- Release as v3.0.0-alpha

### Phase 2: High Priority (Week 2)
- Implement GROUP B (B1-B5)
- Release as v3.0.0-beta

### Phase 3: Medium Priority (Week 3)
- Implement GROUP C (C1-C4)
- Release as v3.0.0

### Phase 4: Polish (Week 4)
- Fix bugs from beta testing
- Update CHANGELOG.md
- Tag v3.0.0 release

---

## Success Criteria

**v3.0.0 Release:**
- ✅ BYOK support (Anthropic + OpenAI)
- ✅ Mode switching (driver, approval, autopilot)
- ✅ Cursor/Claude Code integration (.cursorrules + docs)
- ✅ Preflight safety checks
- ✅ Comprehensive docs (TOC, WHERE_TO_START, CLAUDE_SETUP, CURSOR_GUIDE, AI_GUARDRAILS)
- ✅ Shellcheck CI
- ✅ No breaking changes to existing workflows

**Metrics:**
- Time to first app: <10 minutes (including API key setup)
- Docs findability: <2 clicks to any topic
- Preflight pass rate: >95% for new projects
- CI pass rate: 100% for toolkit self-tests
