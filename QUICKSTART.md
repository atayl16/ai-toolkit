# ⚡ Quick Start Guide

Get up and running with the AI Toolkit in 5 minutes.

---

## 🎯 Prerequisites Check

Before starting, verify you have:

```bash
# Check installations
ruby -v          # Should be 3.3+
rails -v         # Should be installed
docker ps        # Docker should be running
git --version    # Git installed
```

---

## 📥 Installation (First Time Only)

### 1. Add to Shell
Add these lines to `~/.zshrc`:

```bash
# AI Development Toolkit
export PATH="$HOME/.ai-toolkit/bin:$PATH"
source "$HOME/.ai-toolkit/bin/functions.sh"
source "$HOME/.ai-toolkit/bin/completions.zsh"
```

### 2. Reload Shell
```bash
source ~/.zshrc
```

### 3. Verify Installation
```bash
dev help
# You should see the command list
```

✅ **You're installed!** Now let's use it.

---

## 🚀 Create Your First Rails App

### Option A: Standard Rails App

```bash
# 1. Create app (takes 2-3 minutes)
dev new rails TodoApp

# 2. Navigate to it
cd TodoApp

# 3. Run tests (should all pass)
just test

# 4. Run security scans
dev scans

# 5. Start server
just run
# Visit: http://localhost:3000
```

### Option B: Rails API + React

```bash
# 1. Create full-stack app
dev new rails-react FullStackApp

# 2. Start backend
cd FullStackApp
just run
# Backend: http://localhost:3000

# 3. Start frontend (new terminal)
cd client
npm run dev
# Frontend: http://localhost:5173
```

---

## 🛠️ Start Development Services (Optional)

**Note:** Apps use SQLite by default. Only start these if you need PostgreSQL/Redis:

```bash
# Start all services
dev stack up

# Check they're running
docker ps

# Services available at:
# - PostgreSQL: localhost:5432
# - Redis: localhost:6379
# - Mailhog: http://localhost:8025

# Stop when done
dev stack down
```

---

## 📋 Daily Workflow

### Morning Routine
```bash
# 1. Navigate to project
cd ~/code/myproject

# 2. Start services (if needed)
dev stack up

# 3. Pull latest changes
git pull

# 4. Update dependencies
bundle install

# 5. Run migrations
just migrate

# 6. Run tests to verify everything works
just test

# 7. Start server
just run
```

### Before Committing
```bash
# 1. Fix any linting issues
just lint-fix

# 2. Run tests
just test

# 3. Run security scans
dev scans

# 4. Review changes
git diff

# 5. Commit
git add .
git commit -m "Your message"
git push
```

### End of Day
```bash
# Stop dev services
dev stack down

# Commit work in progress
git add .
git commit -m "WIP: description"
git push
```

---

## 🎨 Working with AI Planning

### Create a Plan
```bash
# 1. Create plan document
dev plan "User Authentication"

# 2. Opens in Cursor/VS Code
# Fill in sections with AI assistance

# 3. Implement step-by-step
# Mark off tasks as complete: [x]
```

---

## 🔒 Interview Code Review

Safely review code in isolation:

```bash
# 1. Create isolated sandbox
dev sandbox https://github.com/company/interview-repo

# 2. Automatic security scans run
# Check: ~/Desktop/interviews/interview-repo/reports/

# 3. Enter container to explore
cd ~/Desktop/interviews/interview-repo
docker compose exec app bash

# Inside container:
bundle install
bundle exec rspec
exit

# 4. Review locally
cat reports/brakeman.txt
cat reports/gitleaks.json
```

---

## 🔧 Bootstrap Existing Project

Add AI toolkit to an existing Rails project:

```bash
# 1. Navigate to project
cd ~/code/existing-project

# 2. Bootstrap
dev bootstrap

# 3. Commit the new configs
git add .
git commit -m "Add AI toolkit configs"

# 4. Install Overcommit hooks
bundle install
bundle exec overcommit --install

# 5. Run initial scans
dev scans
```

---

## 💡 Most Used Commands

Keep these handy:

```bash
# Development
just run                 # Start Rails
just console             # Rails console
just test                # Run tests
just lint-fix            # Fix code style

# Services
dev stack up/down        # Manage services

# Quality
dev scans                # All security scans
just ci                  # Full CI check

# Database
just migrate             # Run migrations
just db-reset            # Reset DB

# AI Tools
dev plan "Feature"       # Create plan
dev bootstrap            # Add configs
```

---

## 🆘 Common Issues

### Command not found: dev
```bash
# Add to ~/.zshrc and reload
source ~/.zshrc
```

### Docker not starting
```bash
# Open Docker Desktop app
# Or restart it
```

### Gems not installing
```bash
# Update bundler
gem install bundler
bundle install
```

### Tests failing
```bash
# Reset test database
RAILS_ENV=test just db-reset
just test
```

### Port already in use
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Or use different port
rails s -p 3001
```

---

## 📚 Learn More

- **Full Documentation**: `README.md`
- **Command Reference**: `CHEATSHEET.md`
- **Sample Workflows**: `WORKFLOWS.md`
- **What Changed**: `DIFF_SUMMARY.md`

---

## 🎯 Next Steps

1. ✅ Create your first app
2. ✅ Try the dev stack
3. ✅ Run security scans
4. ✅ Create an AI plan
5. ✅ Bootstrap an existing project

**You're ready to build! 🚀**

---

*Quick Start Guide | AI Development Toolkit | October 2025*

