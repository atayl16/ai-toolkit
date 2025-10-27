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
