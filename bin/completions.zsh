#compdef dev
# Zsh completion for dev command (v2.1.0)
# Install: Add to ~/.zshrc: source ~/.ai-toolkit/bin/completions.zsh

_dev() {
  local -a commands
  commands=(
    'new:Create new Rails, Rails+React, or JobWizard app'
    'sandbox:Clone repo into Docker sandbox for interview'
    'bootstrap:Add AI configs to current project'
    'plan:Create AI planning structure and plan doc'
    'scans:Run security and quality scans'
    'dc:Devcontainer operations'
    'ci:Add CI/CD workflows'
    'stack:Start/stop development stack'
    'diag:Run toolkit diagnostics'
    'upgrade:Upgrade toolkit gems and optionally brew'
    'quickstart:Open Desktop quickstart folder'
    'toolkit:Open ~/.ai-toolkit'
    'help:Show usage information'
  )

  local -a new_types
  new_types=(
    'rails:Rails app with PostgreSQL and Tailwind'
    'rails-react:Rails API + React (Vite) full-stack app'
    'jobwizard:JobWizard app (job tracking + resume builder)'
  )

  local -a stack_cmds
  stack_cmds=(
    'up:Start development stack (Postgres/Redis/Mailhog)'
    'down:Stop development stack'
  )

  local -a dc_cmds
  dc_cmds=(
    'add:Add Rails+Postgres devcontainer to current project'
  )

  local -a ci_cmds
  ci_cmds=(
    'add:Add CI/CD workflow (github-rails or github-node)'
  )

  local -a ci_types
  ci_types=(
    'github-rails:GitHub Actions workflow for Rails'
    'github-node:GitHub Actions workflow for Node.js'
  )

  local -a upgrade_flags
  upgrade_flags=(
    '--brew:Also run brew update && brew upgrade'
  )

  local -a sandbox_flags
  sandbox_flags=(
    '--private:Use temporary directory (auto-deleted)'
  )

  _arguments -C \
    '1: :->command' \
    '*::arg:->args'

  case $state in
    command)
      _describe -t commands 'dev command' commands
      ;;
    args)
      case $words[1] in
        new)
          if (( CURRENT == 2 )); then
            _describe -t new_types 'project type' new_types
          else
            _message 'AppName'
          fi
          ;;
        stack)
          _describe -t stack_cmds 'stack command' stack_cmds
          ;;
        dc)
          _describe -t dc_cmds 'devcontainer command' dc_cmds
          ;;
        ci)
          if (( CURRENT == 2 )); then
            _describe -t ci_cmds 'ci command' ci_cmds
          elif (( CURRENT == 3 )); then
            _describe -t ci_types 'CI type' ci_types
          fi
          ;;
        sandbox)
          if (( CURRENT == 2 )); then
            _message 'git_url'
          else
            _describe -t sandbox_flags 'sandbox flags' sandbox_flags
          fi
          ;;
        upgrade)
          _describe -t upgrade_flags 'upgrade flags' upgrade_flags
          ;;
        plan)
          _message 'Plan title'
          ;;
        bootstrap|scans|diag|quickstart|toolkit|help)
          # No additional arguments
          ;;
      esac
      ;;
  esac
}

compdef _dev dev
