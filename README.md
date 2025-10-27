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

This toolkit provides a unified command interface, templates, and automation for:
- **Rapid Rails scaffolding** with security, testing, and quality tools pre-configured
- **Interview code review** in isolated Docker sandboxes
- **AI-driven planning** with structured templates and prompts
- **Development workflows** optimized for Cursor/Claude integration

Inspired by [andynu's AI planning gist](https://gist.github.com/andynu/ddd235215de9cd2b575bbe4c6b77cadd).

## Installation

### 1. Clone this repo to `~/.ai-toolkit`

```bash
git clone <your-repo> ~/.ai-toolkit
```

### 2. Add to your shell PATH

Add to `~/.zshrc`:

```bash
# AI Toolkit
export PATH="$HOME/.ai-toolkit/bin:$PATH"
source "$HOME/.ai-toolkit/bin/functions.sh"
```

Then reload:

```bash
source ~/.zshrc
```

### 3. Install dependencies

Required:
- **Homebrew** (macOS package manager)
- **Docker Desktop** (containers)
- **rbenv** (Ruby version management)
- **Rails** (`gem install rails`)
- **Git** + **GitHub CLI** (`brew install gh`)

Recommended:
- **Gitleaks** (`brew install gitleaks`) - secret scanning
- **Just** (`brew install just`) - command runner
- **Cursor** or **VS Code** - AI-powered editor

## Usage

### `dev` Command

The main command interface for all toolkit operations.

#### Create New Projects

```bash
# Rails app with Tailwind, SQLite, RSpec, RuboCop, security tools
dev new rails MyApp

# Rails API + React (Vite) in client/ folder
dev new rails-react MyFullStackApp
```

#### Interview Sandbox

Safely review code in isolated Docker environment:

```bash
dev sandbox https://github.com/company/interview-repo
```

This will:
1. Clone repo to `~/Desktop/interviews/`
2. Set up Docker container with DB
3. Run security scans (gitleaks, brakeman, bundler-audit)
4. Generate reports in `reports/`

#### Bootstrap Existing Repos

Add AI configs to existing projects:

```bash
cd my-existing-project
dev bootstrap
```

Adds: `.rubocop.yml`, `.overcommit.yml`, `Justfile`, `.gitignore`, `ai/` directory structure.

#### AI Planning

Initialize AI planning structure:

```bash
dev plan "User Authentication Feature"
```

Creates:
- `ai/plans/YYYYMMDD-user-authentication-feature.md`
- Opens in Cursor/VS Code

#### Quality Scans

Run all security and quality checks:

```bash
dev scans
```

Runs:
- Gitleaks (secrets)
- Brakeman (Rails security)
- Bundler-audit (gem vulnerabilities)
- RuboCop (Ruby linting)
- ESLint (JavaScript linting)

#### Development Stack (Optional)

Start shared services for PostgreSQL/Redis work:

```bash
dev stack up
```

Services:
- PostgreSQL: `localhost:5432` (user: postgres, pass: postgres)
- Redis: `localhost:6379`
- Mailhog: `http://localhost:8025`

**Note:** Apps use SQLite by default. Only run `dev stack up` if you need PostgreSQL/Redis.

Stop:

```bash
dev stack down
```

#### Devcontainers

Add VS Code/Cursor devcontainer:

```bash
dev dc add
```

#### Quick Access

```bash
dev quickstart  # Open ~/Desktop/Dev Quickstart
dev toolkit     # Open ~/.ai-toolkit
dev help        # Show usage
```

## Directory Structure

```
~/.ai-toolkit/
├── bin/
│   ├── dev              # Main command dispatcher
│   └── functions.sh     # Shell helper functions
├── devcontainers/
│   └── rails-postgres/  # VS Code devcontainer config (optional)
├── interview-sandbox/   # Docker setup for code review
├── prompts/             # AI prompt templates
│   ├── plan.prompt      # Feature planning
│   ├── design.prompt    # Architecture design
│   ├── migration.prompt # Safe DB migrations
│   ├── review.prompt    # Code review
│   └── testgen.prompt   # Test generation
├── rails/
│   └── ai_rails.rb      # Rails application template
├── stacks/
│   └── rails-pg-redis-mailhog.yml  # Shared dev services
├── templates/
│   ├── rails/           # Rails config templates
│   │   ├── .rubocop.yml
│   │   ├── .overcommit.yml
│   │   ├── Justfile
│   │   └── .erdconfig
│   ├── claude.md        # Project context template
│   ├── plan.md          # Feature plan template
│   └── execplan.md      # Execution plan template
└── README.md            # This file
```

## Rails Template Features

When you create a new Rails app with `dev new rails`, you get a **tiered setup**:

### TIER 1: Essential (Always Included)
- **RSpec** testing framework
- **FactoryBot & Faker** for test data
- **RuboCop** for code quality
- **Overcommit** git hooks
- **dotenv-rails** for environment variables
- **bundler-audit** for security scanning
- **Justfile** for common tasks
- Custom `bin/setup` script
- Pre-created `reports/` and `docs/` directories

### TIER 2: Optional (Add When Needed)
Performance and debugging tools you can add later:
- **bullet** - N+1 query detection
- **rack-mini-profiler** - Performance profiling
- **annotate** - Model annotations
- **database_cleaner** - Test isolation
- **simplecov** - Test coverage reports
- **rails-erd** - ERD generation

See [TEMPLATE_TIERS.md](TEMPLATE_TIERS.md) for details on adding Tier 2 gems.

## AI Prompts & Modes

The `prompts/` directory contains templates for common AI tasks:

### Core Prompts
- **`plan.prompt`** - Feature implementation plans
- **`design.prompt`** - Architectural design
- **`migration.prompt`** - Safe database migrations
- **`review.prompt`** - Code review checklist
- **`testgen.prompt`** - RSpec test generation
- **`diagnostic.prompt`** - Break out of bug loops

### AI Modes (`prompts/modes.prompt`)
17 specialized modes including:
- **driver-review** - You code, AI reviews
- **plan-approve** - AI writes with approvals
- **autopilot** - AI writes everything
- **bug-surgeon** - Fast, surgical fixes
- **refactor-gardener** - Behavior-preserving refactor
- **ui-iterate** - Quick UX improvements
- **tdd-coach** - Test-first development
- **oss-contrib** - OSS contribution proposals
- **security-scan** - Secrets & vulns hygiene
- **perf-profiler** - Performance optimization
- **local-only-privacy** - No cloud services
- And 7 more specialized modes

See `prompts/modes.prompt` for complete list and usage.

## Workflow Example

### New Rails App

```bash
# 1. Create app
dev new rails TaskManager

# 2. Navigate and verify
cd TaskManager
just test  # Run tests
just lint  # Run linter
dev scans  # Security checks

# 3. Plan a feature
dev plan "Task Assignment"

# 4. Implement in Cursor with AI
# Use prompts from ai/context/claude.md

# 5. Verify
just test
just sec
git commit -m "Add task assignment"
```

### Interview Code Review

```bash
# 1. Set up sandbox
dev sandbox https://github.com/company/coding-challenge

# 2. Enter container
cd ~/Desktop/interviews/coding-challenge
docker compose exec app bash

# 3. Explore
bundle install
bundle exec rspec
exit

# 4. Review reports
cat reports/brakeman.txt
cat reports/gitleaks.json
```

### OSS Contributions

```bash
# 1. Initialize OSS context
dev oss init owner/repo

# 2. List issues
dev oss issues owner/repo

# 3. Create fix plan
dev oss plan "Fix bug XYZ"

# 4. Create repro test
dev oss repro "Issue #123"

# 5. Sync fork
dev oss sync
```

## Customization

### Modify Rails Template

Edit `~/.ai-toolkit/rails/ai_rails.rb` to add gems or change defaults.

### Update Config Templates

Configs in `templates/rails/` are copied to new projects. Update once, apply everywhere.

### Add New Prompts

Create `.prompt` files in `prompts/` directory. Reference in your AI conversations.

### Custom Stacks

Add new Docker Compose files to `stacks/` for different service combinations.

## Tips & Best Practices

### Git Hooks
Overcommit runs on every commit. To skip (emergencies only):
```bash
git commit --no-verify
```

### Docker Cleanup
Periodically clean up:
```bash
docker system prune -a --volumes
```

### RuboCop Autocorrect
Fix auto-correctable issues:
```bash
just lint-fix
```

### ERD Generation
Generate entity-relationship diagram:
```bash
just erd
# Opens docs/erd.png
```

### Planning Workflow
1. `dev plan "Feature Name"` - Create plan
2. Use `ai/context/claude.md` with Cursor
3. Implement step-by-step
4. Update plan with `[x]` as you complete tasks
5. Commit often, test continuously

## Troubleshooting

### `command not found: dev`
- Ensure `~/.ai-toolkit/bin` is in your PATH
- Run `source ~/.zshrc`

### Shell functions not found
- Source the functions: `source ~/.ai-toolkit/bin/functions.sh`
- Add to `~/.zshrc` for persistence

### Docker permission issues
- Ensure Docker Desktop is running
- Check user is in `docker` group (Linux)

### RuboCop conflicts
- Templates are opinionated; adjust `.rubocop.yml` as needed
- Use `rubocop --auto-gen-config` for project-specific overrides

## Maintenance

### Update Toolkit

```bash
cd ~/.ai-toolkit
git pull origin main
```

### Sync Templates

After updating templates, bootstrap existing projects:

```bash
cd my-old-project
dev bootstrap
```

## Contributing

This is a personal toolkit, but feel free to fork and adapt!

## License

MIT - Use freely, no attribution required.

---

**Built with ❤️ and AI by Alisha Taylor**

