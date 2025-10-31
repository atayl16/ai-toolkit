# Changelog

All notable changes to the AI Development Toolkit.

## [2.1.0] - 2025-10-21

### Added
- **Diagnostics Command** (`dev diag`)
  - Checks versions of ruby, rails, node, docker, git
  - Verifies rbenv shims in PATH
  - Validates required gems: brakeman, bundler-audit, rubocop*, overcommit
  - Checks CLI tools: gitleaks, jq, yq, fzf
  - Verifies template files exist
  - Exit codes for CI/automation

- **GitHub Actions CI Templates**
  - `dev ci add github-rails` - Rails CI workflow
  - `dev ci add github-node` - Node.js CI workflow
  - Templates include: RuboCop, RSpec, Brakeman, Bundler-audit
  
- **Enhanced Rails+React**
  - ESLint + Prettier + Husky pre-commit hooks
  - TypeScript-ready configuration
  - .editorconfig for consistent formatting
  - Extracted to `templates/react/` for reuse
  - Documents dev ports (3000 API, 5173 client)
  
- **Secret-Scan Configuration**
  - `.gitleaks.toml` template with sensible allowlists
  - Reduces false positives (UUIDs, test keys)
  - `scan_here` prefers this config if present
  
- **Toolchain Upgrade** (`dev upgrade`)
  - Updates global gems (rubocop, brakeman, etc.)
  - Optional `--brew` flag for Homebrew updates
  - Shows before/after versions
  
- **Sandbox Improvements**
  - `--private` flag for temporary directories
  - Docker running check with friendly error
  - Timestamped sandbox reports
  - Better scan integration

### Changed
- **RuboCop Template** - More robust configuration
  - Added header comments explaining choices
  - LineLength: 120 (was 110)
  - Disabled FrozenStringLiteralComment
  - Better exclusions for generated files
  
- **Help Text** - Expanded with new commands and examples
- **Completions** - Updated with all new commands and flags
- **Documentation** - Added architecture section to README.md

### Fixed
- Error handling when Docker isn't running
- Template file copying now idempotent
- RuboCop config properly replaces TargetRubyVersion

## [2.0.0] - 2025-10-21

### Added
- **Shell Functions Library** (`bin/functions.sh`) - All helper functions now self-contained
  - `scan_here` - Security and quality scanning
  - `new_interview` - Interview sandbox creation
  - `ai_bootstrap_repo` - Bootstrap existing repos
  - `ai_init_here` / `ai_new_plan` - AI planning workflow
  - `dc_add_rails_pg` - Devcontainer setup
  - `stack_up` / `stack_down` - Development stack management
  
- **Template Extraction** - Moved configs from heredocs to `templates/rails/`
  - `.rubocop.yml` - Enhanced with more sensible defaults
  - `.overcommit.yml` - Git hooks configuration
  - `Justfile` - Added more commands (lint-fix, test-cov, db-reset, ci)
  - `.erdconfig` - Rails ERD configuration
  - `bin_setup` - Custom setup script
  
- **Documentation**
  - Comprehensive `README.md` with examples and workflows
  - `CHANGELOG.md` (this file)
  - `INSTALL.md` - Installation guide
  - `UPGRADE_NOTES.md` - Migration guide
  - `DIFF_SUMMARY.md` - Complete diff breakdown
  - Inline comments in all scripts
  
- **Shell Completion** - Zsh completion for `dev` command
- **Base Dockerfile** - Reusable base image template
- **Version Control** - `.gitignore` for toolkit

### Changed
- **YAML Standardization** - All Docker Compose files use consistent block format
- **Docker Images** - Switched to Alpine variants for smaller image sizes
- **Enhanced Docker Compose** - Added database names, restart policies, volume persistence
- **Updated `ai_rails.rb`** - Now references extracted templates instead of inline heredocs
- **Improved Dockerfiles** - Added comments and better organization

### Fixed
- Missing shell function implementations that `bin/dev` depended on
- Code duplication between devcontainer and interview-sandbox Dockerfiles
- Inconsistent YAML formatting across compose files
- Missing template files for bootstrap operations

## [1.0.0] - Initial Version

### Initial Implementation
- `bin/dev` command dispatcher
- Rails application template (`ai_rails.rb`)
- AI prompt templates
- Docker configurations
- Development stack setup
