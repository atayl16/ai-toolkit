# 🚀 AI Toolkit Command Cheatsheet

Quick reference for the most common commands.

---

## 🎯 Essential Commands

### Creating Projects
```bash
dev new rails MyApp              # Rails app with all the tools
dev new rails-react FullStack    # Rails API + React frontend
```

### Project Setup
```bash
dev bootstrap                    # Add configs to existing project
dev dc add                       # Add devcontainer support
```

### Quality & Security
```bash
dev scans                        # Run all scans (gitleaks, brakeman, etc)
just lint                        # Run RuboCop
just lint-fix                    # Auto-fix RuboCop issues
just sec                         # Security scans only
just ci                          # Full CI (lint + sec + test)
```

### Development Services
```bash
dev stack up                     # Start Postgres + Redis + Mailhog
dev stack down                   # Stop all services
```

### Testing
```bash
just test                        # Run RSpec
just test-cov                    # Run tests with coverage report
```

### AI Planning & Modes
```bash
dev plan "Feature Name"          # Create AI planning document
ai_diagnose                      # Break out of bug loops (diagnostic prompt)
# See prompts/modes.prompt for 17 specialized AI modes
```

### Database
```bash
just migrate                     # Run migrations
just rollback                    # Rollback last migration
just db-reset                    # Reset database completely
```

### Rails Commands
```bash
just run                         # Start Rails server
just console                     # Rails console
just erd                         # Generate ERD diagram
```

### Interview Code Review & OSS Contributions
```bash
dev sandbox https://github.com/company/repo
# Clones, isolates, and scans in Docker

dev oss init owner/repo         # Initialize OSS context
dev oss harvest                 # Re-harvest context
dev oss issues owner/repo       # List open issues
dev oss plan "Feature"          # Create OSS plan
dev oss repro "Issue #123"     # Create repro skeleton
dev oss sync                    # Sync fork with upstream
```

---

## 🌐 Service URLs (Optional)

When `dev stack up` is running (optional - apps use SQLite by default):

```
PostgreSQL:  localhost:5432  (user: postgres, pass: postgres)
Redis:       localhost:6379
Mailhog UI:  http://localhost:8025
```

---

## 📂 Common File Locations

```bash
~/.ai-toolkit/               # Toolkit home
~/Desktop/interviews/        # Interview sandboxes
ai/plans/                    # AI planning docs
ai/context/                  # Project context
reports/                     # Security scan reports
docs/                        # Project docs & ERDs
```

---

## 🔧 Useful One-Liners

```bash
# Quick project health check
just ci

# Full security sweep
dev scans && cat reports/brakeman.txt

# Reset everything
just db-reset && just test

# Start fresh dev session
dev stack up && just run

# Bootstrap + initial scan
dev bootstrap && dev scans

# Create plan and open in editor
dev plan "User Auth" && cursor ai/plans/*.md
```

---

## 🎨 Shell Functions

Available anywhere in your terminal:

```bash
scan_here                    # Run all scans in current dir
ai_bootstrap_repo            # Add AI configs
ai_init_here                 # Init AI planning structure
ai_new_plan "Title"          # Create new plan
ai_diagnose                  # Open diagnostic recovery prompt (break bug loops!)
new_interview <git_url>      # Create interview sandbox
stack_up / stack_down        # Manage dev services
```

---

## 💡 Pro Tips

### Tab Completion
```bash
dev <TAB>                    # See all commands
dev new <TAB>               # rails or rails-react
dev stack <TAB>             # up or down
```

### Workflow Shortcuts
```bash
# Morning routine
alias morning="dev stack up && cd ~/code/myproject && just run"

# Quick commit check
alias precommit="just lint-fix && just test"

# Interview prep
alias review="cd ~/Desktop/interviews && ls -la"
```

### Environment Variables
```bash
# In your .env file
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/myapp_development
REDIS_URL=redis://localhost:6379/0
SMTP_ADDRESS=localhost
SMTP_PORT=1025
```

---

## 🆘 Troubleshooting

```bash
# Dev command not found
source ~/.zshrc

# Functions not available
source ~/.ai-toolkit/bin/functions.sh

# Docker issues
docker system prune -a              # Clean up
dev stack down && dev stack up      # Restart services

# Gems outdated
bundle update

# Database issues
just db-reset
```

---

**📌 Pin this file to your Desktop for quick access!**

*Updated: October 2025*

