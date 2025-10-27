#!/usr/bin/env bash
# AI Toolkit Shell Functions
# Source this in your ~/.zshrc: source ~/.ai-toolkit/bin/functions.sh

# Colors and output helpers
_ai_info() { printf "\033[36m➜\033[0m %s\n" "$*"; }
_ai_err() { printf "\033[31m✗\033[0m %s\n" "$*" >&2; }
_ai_success() { printf "\033[32m✓\033[0m %s\n" "$*"; }

# Check if a command exists
_ai_need() { command -v "$1" >/dev/null 2>&1 || { _ai_err "Missing dependency: $1"; return 1; }; }

# Security & Quality Scans
scan_here() {
  _ai_info "Running security and quality scans..."
  mkdir -p reports
  
  # Gitleaks - secret scanning
  if _ai_need gitleaks; then
    _ai_info "Running gitleaks..."
    gitleaks detect --no-banner --report-path reports/gitleaks.json || true
  fi
  
  # Brakeman - Rails security scanner
  if [ -f Gemfile ] && grep -q 'rails' Gemfile; then
    if _ai_need brakeman; then
      _ai_info "Running brakeman..."
      bundle exec brakeman -q -o reports/brakeman.txt || true
    fi
  fi
  
  # Bundler-audit - gem vulnerability checking
  if [ -f Gemfile.lock ]; then
    if _ai_need bundler-audit; then
      _ai_info "Running bundler-audit..."
      bundle exec bundler-audit update && bundle exec bundler-audit check || true
    fi
  fi
  
  # RuboCop - Ruby linting
  if [ -f .rubocop.yml ]; then
    if _ai_need rubocop; then
      _ai_info "Running rubocop..."
      bundle exec rubocop || true
    fi
  fi
  
  # ESLint - JavaScript linting
  if [ -f .eslintrc.js ] || [ -f .eslintrc.json ]; then
    if _ai_need eslint; then
      _ai_info "Running eslint..."
      npx eslint . --ext .js,.jsx,.ts,.tsx || true
    fi
  fi
  
  _ai_success "Scans complete. Check reports/ directory."
}

# Interview Sandbox - Clone repo into isolated Docker environment
new_interview() {
  local git_url="${1:-}"
  if [ -z "$git_url" ]; then
    _ai_err "Usage: new_interview <git_url>"
    return 1
  fi
  
  _ai_need git
  _ai_need docker
  _ai_need gitleaks
  
  # Extract repo name from URL
  local repo_name
  repo_name=$(basename "$git_url" .git)
  local sandbox_dir="$HOME/Desktop/interviews/$repo_name"
  
  _ai_info "Creating interview sandbox: $repo_name"
  mkdir -p "$(dirname "$sandbox_dir")"
  
  # Clone repo
  _ai_info "Cloning repository..."
  git clone "$git_url" "$sandbox_dir"
  cd "$sandbox_dir" || return 1
  
  # Copy sandbox docker setup
  _ai_info "Setting up Docker environment..."
  cp -r "$HOME/.ai-toolkit/interview-sandbox/." .
  
  # Run initial scans
  _ai_info "Running initial security scans..."
  bash setup.sh
  
  _ai_success "Interview sandbox ready at: $sandbox_dir"
  _ai_info "Next steps:"
  echo "  cd $sandbox_dir"
  echo "  docker compose exec app bash  # Enter container"
}

# Bootstrap Repository - Add AI configs to existing project
ai_bootstrap_repo() {
  _ai_info "Bootstrapping repository with AI configs..."
  
  local toolkit="$HOME/.ai-toolkit"
  mkdir -p reports docs ai
  
  # Add RuboCop if Ruby project
  if [ -f Gemfile ] && [ ! -f .rubocop.yml ]; then
    _ai_info "Adding .rubocop.yml..."
    cp "$toolkit/templates/rails/.rubocop.yml" .
  fi
  
  # Add Overcommit if not present
  if [ -f Gemfile ] && [ ! -f .overcommit.yml ]; then
    _ai_info "Adding .overcommit.yml..."
    cp "$toolkit/templates/rails/.overcommit.yml" .
    bundle exec overcommit --install 2>/dev/null || true
  fi
  
  # Add Justfile if not present
  if [ ! -f Justfile ]; then
    _ai_info "Adding Justfile..."
    cp "$toolkit/templates/rails/Justfile" .
  fi
  
  # Add .gitignore additions
  if [ ! -f .gitignore ]; then
    _ai_info "Creating .gitignore..."
    cat > .gitignore <<'EOF'
.DS_Store
*.log
/tmp/
/log/
/coverage/
/reports/
.env
.env.local
node_modules/
ai/
.ai-local/
EOF
  fi
  
  _ai_success "Repository bootstrapped."
}

# Initialize AI planning directory structure
ai_init_here() {
  local title="${1:-Kickoff}"
  _ai_info "Initializing AI planning structure..."
  
  mkdir -p ai/plans ai/context ai/scratch
  
  # Copy context template if not exists
  if [ ! -f ai/context/claude.md ]; then
    cp "$HOME/.ai-toolkit/templates/claude.md" ai/context/
  fi
  
  _ai_success "AI structure initialized: ai/"
}

# Create a new AI plan document
ai_new_plan() {
  local title="${1:-Feature}"
  local slug
  slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')
  local prefix
  prefix=$(date +%Y%m%d)
  local filename="ai/plans/${prefix}-${slug}.md"
  
  _ai_info "Creating plan: $filename"
  
  # Use template
  sed -e "s/{{PREFIX}}/$prefix/g" \
      -e "s/{{SLUG}}/$slug/g" \
      "$HOME/.ai-toolkit/templates/plan.md" > "$filename"
  
  _ai_success "Plan created: $filename"
  
  # Open in editor if available
  if command -v code >/dev/null 2>&1; then
    code "$filename"
  elif command -v cursor >/dev/null 2>&1; then
    cursor "$filename"
  else
    echo "Open: $filename"
  fi
}

# Add devcontainer to current project
dc_add_rails_pg() {
  _ai_info "Adding Rails + Postgres devcontainer..."
  
  mkdir -p .devcontainer
  cp "$HOME/.ai-toolkit/devcontainers/rails-postgres/devcontainer.json" .devcontainer/
  cp "$HOME/.ai-toolkit/devcontainers/rails-postgres/docker-compose.yml" .devcontainer/
  cp "$HOME/.ai-toolkit/devcontainers/rails-postgres/Dockerfile" .devcontainer/
  
  _ai_success "Devcontainer added. Reopen in container (VS Code/Cursor)."
}

# Start development stack (Postgres + Redis + Mailhog)
stack_up() {
  _ai_info "Starting development stack..."
  _ai_need docker
  
  local stack_file="$HOME/.ai-toolkit/stacks/rails-pg-redis-mailhog.yml"
  docker compose -f "$stack_file" -p ai-stack up -d
  
  _ai_success "Stack running:"
  echo "  PostgreSQL: localhost:5432 (user: postgres, pass: postgres)"
  echo "  Redis:      localhost:6379"
  echo "  Mailhog UI: http://localhost:8025"
  echo ""
  echo "Stop with: dev stack down"
}

# Stop development stack
stack_down() {
  _ai_info "Stopping development stack..."
  
  local stack_file="$HOME/.ai-toolkit/stacks/rails-pg-redis-mailhog.yml"
  docker compose -f "$stack_file" -p ai-stack down
  
  _ai_success "Stack stopped."
}

# AI Diagnostic - Help break out of bug loops
ai_diagnose() {
  local prompt_file="$HOME/.ai-toolkit/prompts/diagnostic.prompt"
  
  if [ -f "$prompt_file" ]; then
    _ai_info "Opening AI Diagnostic Recovery Prompt..."
    if command -v open >/dev/null 2>&1; then
      open "$prompt_file" 2>/dev/null || cat "$prompt_file"
    else
      cat "$prompt_file"
    fi
  else
    _ai_err "Diagnostic prompt not found at: $prompt_file"
    return 1
  fi
}

run_preflight() {
  "$TOOLKIT_DIR/bin/preflight"
}

ai_set_mode() {
  "$TOOLKIT_DIR/bin/ai-mode" "$@"
}

# Export all functions
export -f scan_here new_interview ai_bootstrap_repo ai_init_here ai_new_plan dc_add_rails_pg stack_up stack_down ai_diagnose run_preflight ai_set_mode

_ai_success "AI Toolkit functions loaded."

