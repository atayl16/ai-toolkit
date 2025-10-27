# Rails Template Tiers

The AI Rails template uses a **tiered approach** to keep new apps lean but powerful.

## TIER 1: Essential (Always Included)

**Purpose:** Quality and security from day one

**Gems:**
- `rspec-rails` - Testing framework
- `factory_bot_rails` - Test data factories
- `faker` - Realistic fake data
- `rubocop`, `rubocop-rails`, `rubocop-rspec` - Code quality
- `overcommit` - Git hooks
- `dotenv-rails` - Environment variables
- `bundler-audit` - Security scanning

**Why:** These are non-negotiable for production-ready Rails apps.

---

## TIER 2: Optional (Add When Needed)

**Purpose:** Performance tuning, debugging, documentation

**Gems:**
- `bullet` - N+1 query detection
- `rack-mini-profiler` - Performance profiling
- `annotate` - Model annotations
- `database_cleaner-active_record` - Test isolation
- `simplecov` - Test coverage reports
- `rails-erd` - ERD generation

**When to add:**
- **bullet** - When you need to catch N+1 queries
- **rack-mini-profiler** - When profiling performance
- **annotate** - When documenting models
- **database_cleaner** - If test isolation issues arise
- **simplecov** - When tracking test coverage
- **rails-erd** - When generating ERDs

---

## How to Add Tier 2

### Option 1: Add gems manually
```bash
# In your Rails app
bundle add bullet --group development
bundle add rack-mini-profiler --group development
bundle add annotate --group development
bundle add database_cleaner-active_record --group test
bundle add simplecov --group test
bundle add rails-erd --group development
```

### Option 2: Edit Gemfile directly
Uncomment the TIER 2 section in `Gemfile`, then:
```bash
bundle install
```

### Option 3: Future command (planned)
```bash
dev tier2 add  # Add all tier 2 gems
```

---

## Why This Approach?

**Problem with "everything included":**
- Slower `bundle install`
- More gems to understand
- Some gems aren't needed until later
- Increases cognitive load

**Tiered approach benefits:**
- ✅ Fast initial setup
- ✅ Essential quality tools from start
- ✅ Add performance tools when needed
- ✅ Clear upgrade path

---

## Migration from Old Template

If you have apps created with the old template (all gems included), you can:

1. **Keep everything** - Old apps work fine
2. **Remove unused gems** - Manually remove gems you don't use
3. **No action needed** - The tiered approach only affects new apps

---

*Updated: 2025-10-23*
