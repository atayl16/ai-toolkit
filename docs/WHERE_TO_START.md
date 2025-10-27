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
