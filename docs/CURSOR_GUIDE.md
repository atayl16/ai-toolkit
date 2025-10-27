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
