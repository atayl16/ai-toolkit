# SESSION KICKOFF

Welcome! This project uses AI Toolkit with structured workflows.

## Available Modes

### DRIVER MODE (You Write, AI Reviews)
- You write code, AI reviews and suggests
- AI generates small bits only when requested (migrations, tests)
- Best for: Learning, tight control, code walkthroughs

### APPROVAL MODE (AI Plans, You Approve)
- AI creates plan with labeled items (A1, A2, B1, B2...)
- You reply "Approve: A1, B3..." to select which to implement
- AI implements only approved items
- Best for: Feature development, refactoring, bug fixes

### AUTOPILOT MODE (AI Implements End-to-End)
- AI implements completely, asks only if blocked
- Small commits (~200 LOC each)
- Best for: Prototypes, repetitive tasks, well-defined features

## Current Mode
[INJECTED BY bin/ai-mode]

## Project Context
Repository: [INJECTED]
Stack: [INJECTED]
Style: [INJECTED]
Conventions: [INJECTED]

## Commands
- `dev plan "Feature"` — Create new plan
- `dev scans` — Run security/quality scans
- `just test` — Run tests
- `just lint-fix` — Auto-fix linting
- `scan_here` — Quick security check

## Getting Started
Describe what you'd like to work on, and I'll proceed in approval mode.
