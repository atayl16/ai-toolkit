# Project Context for AI
- Repo: {{REPO_NAME}}
- Style: Rails conventions, PORO service objects, RSpec, Convention > configuration
- Docs style: terse, task-first
- Performance: prefer eager_load, Bullet clean, avoid N+1

# Prompt Library (inline)
## Plan
"Given: <req>, produce plan.md sections: ExecSummary, TechnicalApproach, Steps, Tests, AC."
## Implement
"Implement Step <n> from {{PREFIX}}-{{SLUG}}. Provide diff-ready code and tests."
## Debug
"Given stack trace <paste>, find likely causes, show minimal fix + tests."
## Review
"Review diff <paste>. Bugs, security, performance, missing tests, concrete fixes."
