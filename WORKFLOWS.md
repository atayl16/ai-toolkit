# 🎯 Sample Workflows

Real-world recipes for common development tasks.

---

## 🚀 Starting a New Feature

### Full Feature Development Cycle

```bash
# 1. Create feature plan
dev plan "Add User Notifications"

# 2. Create feature branch
git checkout -b feature/notifications

# 3. Start services if needed
dev stack up

# 4. Generate models/controllers
rails g model Notification user:references message:text read:boolean

# 5. Run migrations
just migrate

# 6. Write tests first (TDD)
# Edit spec/models/notification_spec.rb

# 7. Run tests (should fail)
just test

# 8. Implement feature
# Edit app/models/notification.rb

# 9. Run tests until green
just test

# 10. Check code quality
just lint-fix

# 11. Full CI check
just ci

# 12. Generate ERD
just erd

# 13. Commit incrementally
git add .
git commit -m "feat: add notification model"

# 14. Push and create PR
git push -u origin feature/notifications
gh pr create --web
```

---

## 🔍 Code Review & Interview Workflow

### Reviewing Candidate Code

```bash
# 1. Create isolated sandbox
dev sandbox https://github.com/candidate/code-challenge

# 2. Check initial scan reports
cd ~/Desktop/interviews/code-challenge
cat reports/gitleaks.json      # Any secrets?
cat reports/brakeman.txt        # Security issues?

# 3. Enter container
docker compose exec app bash

# 4. Inside container - explore code
ls -la
cat README.md
bundle install
bundle exec rubocop             # Code quality?
bundle exec rspec               # Tests pass?
bundle exec rspec --format documentation

# 5. Manual testing
rails db:create db:migrate db:seed
rails console
# Try the main features

exit

# 6. Write feedback
cd ~/Desktop/interviews
cat > code-challenge-review.md << 'EOF'
# Code Review: [Candidate Name]

## Strengths
- [List positives]

## Areas for Improvement
- [List issues]

## Security Concerns
- [From brakeman report]

## Recommendation
- [ ] Hire
- [ ] No
- [ ] Maybe - discuss [specific areas]
EOF

# 7. Cleanup when done
docker compose down -v
cd ~ && rm -rf ~/Desktop/interviews/code-challenge
```

---

## 🏗️ Starting a Greenfield Project

### From Idea to First Commit

```bash
# 1. Plan the architecture
mkdir -p ~/code/myproject
cd ~/code/myproject
dev plan "Project Architecture"
# Fill in: models, APIs, tech stack

# 2. Create Rails app
cd ~/code
dev new rails-react MyProject

# 3. Setup GitHub repo
cd MyProject
gh repo create --private --source=.
git branch -M main
git push -u origin main

# 4. Add project context for AI
cat > ai/context/claude.md << 'EOF'
# MyProject Context

## What We're Building
[Brief description]

## Tech Stack
- Rails 7 API
- React + Vite
- PostgreSQL
- Redis (background jobs)
- Tailwind CSS

## Key Features
1. [Feature 1]
2. [Feature 2]
3. [Feature 3]

## Conventions
- Services in app/services/
- API versioning: /api/v1/
- JSON responses only
EOF

# 5. Setup project board
gh project create --title "MyProject" --owner @me

# 6. Create initial issues
gh issue create --title "Setup CI/CD" --body "Configure GitHub Actions"
gh issue create --title "Setup authentication" --body "Devise + JWT"
gh issue create --title "Setup background jobs" --body "Sidekiq + Redis"

# 7. Start first feature
dev plan "User Authentication"
git checkout -b feature/auth
```

---

## 🐛 Debugging Production Issues

### Investigation Workflow

```bash
# 1. Pull production logs locally
# (assuming you have access)
heroku logs --tail --app myapp > production_errors.log

# 2. Reproduce locally
dev stack up
just run

# 3. Run security scans
dev scans

# 4. Check for known vulnerabilities
bundle exec bundler-audit check --update

# 5. Update vulnerable gems
bundle update [gem-name]

# 6. Run full test suite
just test

# 7. Deploy fix
git add Gemfile Gemfile.lock
git commit -m "fix: update vulnerable dependencies"
git push
```

---

## 🔄 Refactoring Workflow

### Safe Refactoring Process

```bash
# 1. Ensure tests are comprehensive
just test-cov
# Check coverage report: coverage/index.html

# 2. Write additional tests if needed
# Focus on the area you're refactoring

# 3. Create refactor branch
git checkout -b refactor/extract-services

# 4. Run tests before changes
just test  # Should be green

# 5. Make small incremental changes
# Extract one service at a time

# 6. Run tests after each change
just test  # Should stay green

# 7. Check code quality
just lint-fix

# 8. Commit each small refactor
git add app/services/user_notification_service.rb
git commit -m "refactor: extract UserNotificationService"

# 9. Final verification
just ci

# 10. Create PR with clear description
gh pr create --title "Refactor: Extract notification services" \
  --body "Extracts notification logic into service objects for better testability"
```

---

## 🧪 Test-Driven Development (TDD)

### Red-Green-Refactor Cycle

```bash
# 1. Write failing test
# spec/services/email_validator_spec.rb
cat > spec/services/email_validator_spec.rb << 'RUBY'
require 'rails_helper'

RSpec.describe EmailValidator do
  describe '#valid?' do
    it 'returns true for valid emails' do
      validator = EmailValidator.new('user@example.com')
      expect(validator.valid?).to be true
    end

    it 'returns false for invalid emails' do
      validator = EmailValidator.new('invalid-email')
      expect(validator.valid?).to be false
    end
  end
end
RUBY

# 2. Run test (should fail - RED)
bundle exec rspec spec/services/email_validator_spec.rb

# 3. Write minimal code to pass
mkdir -p app/services
cat > app/services/email_validator.rb << 'RUBY'
class EmailValidator
  def initialize(email)
    @email = email
  end

  def valid?
    @email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end
end
RUBY

# 4. Run test (should pass - GREEN)
bundle exec rspec spec/services/email_validator_spec.rb

# 5. Refactor if needed
# Improve code quality while keeping tests green

# 6. Commit
git add app/services/email_validator.rb spec/services/email_validator_spec.rb
git commit -m "feat: add email validator service"
```

---

## 📦 Dependency Updates

### Safe Update Process

```bash
# 1. Check for outdated gems
bundle outdated

# 2. Review CHANGELOG for breaking changes
# Visit gem GitHub repos

# 3. Update in small batches
bundle update rspec-rails factory_bot_rails

# 4. Run full test suite
just test

# 5. Check for deprecation warnings
rails log:clear
just test 2>&1 | grep -i deprecat

# 6. Update one major version at a time
bundle update rails --conservative

# 7. Test thoroughly
just ci

# 8. Security check
bundle exec bundler-audit check

# 9. Commit
git add Gemfile Gemfile.lock
git commit -m "chore: update dependencies"
```

---

## 🚢 Pre-Deployment Checklist

### Before Pushing to Production

```bash
# 1. Pull latest from main
git checkout main
git pull

# 2. Merge your feature branch
git merge feature/your-feature

# 3. Run all scans
dev scans

# 4. Full test suite
just test

# 5. Check linting
just lint

# 6. Check security
just sec

# 7. Review brakeman report
cat reports/brakeman.txt

# 8. Check for secrets
cat reports/gitleaks.json

# 9. Test in production-like environment
RAILS_ENV=production bundle exec rails assets:precompile
RAILS_ENV=production just test

# 10. Generate ERD for documentation
just erd

# 11. Update CHANGELOG
echo "## [Version] - $(date +%Y-%m-%d)" >> CHANGELOG.md
echo "- Added: [features]" >> CHANGELOG.md

# 12. Tag release
git tag -a v1.2.3 -m "Release version 1.2.3"
git push --tags

# 13. Deploy
git push heroku main
# or your deployment command
```

---

## 🎨 AI-Assisted Development

### Using AI Planning Workflow

```bash
# 1. Create high-level plan
dev plan "E-commerce Checkout Flow"

# 2. Use Claude/ChatGPT with context
# Paste content from ai/context/claude.md
# Reference your plan

# 3. Generate implementation steps
# Ask AI: "Break down the checkout flow into implementable steps"

# 4. For each step, ask AI to:
# - Write the migration
# - Write the model
# - Write the tests
# - Write the controller
# - Review for security issues

# 5. Execute incrementally
# Copy AI-generated code
# Run tests: just test
# Verify: just lint
# Commit: git commit -m "step 1: add order model"

# 6. Use AI for code review
git diff | pbcopy
# Paste to AI: "Review this diff for issues"

# 7. Update plan with completion status
# Mark [x] for completed tasks in ai/plans/*.md
```

---

## 🛠️ Daily Maintenance

### Morning Developer Routine

```bash
#!/bin/bash
# Save as ~/bin/morning-dev and chmod +x

echo "☀️  Good morning! Starting dev environment..."

# 1. Start services
dev stack up

# 2. Navigate to main project
cd ~/code/main-project

# 3. Update codebase
git checkout main
git pull

# 4. Update dependencies
bundle install
npm install  # if applicable

# 5. Update database
just migrate

# 6. Run tests to ensure everything works
just test

# 7. Check for security updates
bundle exec bundler-audit check

# 8. Open editor
cursor .

echo "✅ Ready to code!"
```

### Evening Cleanup Routine

```bash
#!/bin/bash
# Save as ~/bin/evening-dev and chmod +x

echo "🌙 Wrapping up..."

# 1. Save any uncommitted work
git add .
git commit -m "WIP: $(date +%Y-%m-%d)" || echo "Nothing to commit"
git push

# 2. Stop services
dev stack down

# 3. Clean up Docker
docker system prune -f

# 4. Summary
echo "✅ All changes pushed"
echo "✅ Services stopped"
echo "✅ Docker cleaned"
echo "💤 Good night!"
```

---

## 🎯 Team Workflow

### Onboarding New Developer

```bash
# As team lead, prepare:
cat > ~/Desktop/onboarding.sh << 'BASH'
#!/bin/bash
echo "🎉 Welcome! Setting up your environment..."

# Install toolkit
git clone https://github.com/yourteam/ai-toolkit ~/.ai-toolkit

# Setup shell
cat >> ~/.zshrc << 'ZSH'
export PATH="$HOME/.ai-toolkit/bin:$PATH"
source "$HOME/.ai-toolkit/bin/functions.sh"
source "$HOME/.ai-toolkit/bin/completions.zsh"
ZSH

source ~/.zshrc

# Clone main repo
git clone https://github.com/yourteam/main-repo ~/code/main-repo
cd ~/code/main-repo

# Setup
dev stack up
bundle install
just migrate
just test

echo "✅ Setup complete! Read ai/context/claude.md for project overview"
BASH

chmod +x ~/Desktop/onboarding.sh

# Share with new developer
```

---

**💡 Pro Tip**: Create shell aliases for your most-used workflows!

```bash
alias morning="dev stack up && cd ~/code/myproject && just test"
alias commit-check="just lint-fix && just test && just sec"
alias deploy-check="just ci && cat reports/brakeman.txt"
```

---

*Workflows Guide | AI Development Toolkit | October 2025*

