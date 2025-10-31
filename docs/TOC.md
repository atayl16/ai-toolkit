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
├── templates/          # Rails/React configs
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
