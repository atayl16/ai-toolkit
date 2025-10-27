# Claude Setup Guide

This guide explains how to use Claude (Anthropic's LLM) with AI Toolkit in Cursor or Claude Code.

## Why Claude?

**Claude is optimized for coding tasks:**
- Strong reasoning and planning
- Large context window (200K tokens)
- Excellent at following structured workflows
- Safe and accurate code generation

**Recommended model:** `claude-sonnet-4-5-20250929`

---

## Option 1: Cursor IDE (BYOK)

### Step 1: Get Anthropic API Key

1. Go to [Anthropic Console](https://console.anthropic.com/)
2. Sign up or log in
3. Navigate to **API Keys**
4. Create new key: "Cursor Development"
5. Copy key (starts with `sk-ant-...`)

### Step 2: Add Key to Cursor

**Method A: Cursor Settings (Recommended)**
1. Open Cursor
2. Go to **Settings** (Cmd+, or Ctrl+,)
3. Navigate to **Accounts & Models**
4. Under **Anthropic**, click **Add API Key**
5. Paste your key
6. Select model: `claude-sonnet-4-5-20250929`

**Method B: Environment Variable**
1. Add to `~/.zshrc` (or `~/.bashrc`):
   ```bash
   export ANTHROPIC_API_KEY="sk-ant-..."
   ```
2. Restart terminal
3. Restart Cursor

### Step 3: Verify Setup

1. Open any project in Cursor
2. Open Cursor Chat (Cmd+L)
3. Type: "Hello, which model are you?"
4. Verify response mentions Claude

---

## Option 2: Claude Code IDE

### Step 1: Get Anthropic API Key

Same as Option 1, Step 1.

### Step 2: Add Key to Claude Code

1. Open Claude Code
2. Go to **Settings**
3. Navigate to **API Keys**
4. Click **Add Key** → **Anthropic**
5. Paste your key
6. Select model: `claude-sonnet-4-5-20250929`

### Step 3: Verify Setup

1. Open any project in Claude Code
2. Open chat panel
3. Type: "Hello, which model are you?"
4. Verify response mentions Claude

---

## Option 3: Environment Variables (CLI Tools)

Some AI Toolkit scripts may use providers directly (e.g., for automation).

### Step 1: Add to Shell Config

Add to `~/.zshrc` (or `~/.bashrc`):
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."  # Optional, for alternate provider
```

### Step 2: Reload Shell

```bash
source ~/.zshrc
```

### Step 3: Verify

```bash
echo $ANTHROPIC_API_KEY  # Should print sk-ant-...
```

**⚠️ WARNING:** Do NOT add keys to project `.env` files that might be committed.

---

## Security Best Practices

### ✅ DO

- Store keys in shell config (`~/.zshrc`) or IDE settings
- Use `.env.local` for project-specific overrides (gitignored)
- Run `dev preflight` to check for leaked secrets
- Rotate keys if accidentally committed

### ❌ DO NOT

- Commit keys to `.env` or any tracked file
- Print keys in logs or error messages
- Share keys in screenshots or screencasts
- Use keys from untrusted sources

### Verify Gitignore

Run this before committing:
```bash
dev preflight
```

This checks:
- `.env` is gitignored
- No `*_API_KEY` in tracked files
- Gitleaks scan passes

---

## Model Selection

### Anthropic Models (Recommended)

| Model | Best For | Context | Cost |
|-------|----------|---------|------|
| `claude-sonnet-4-5-20250929` | **Coding** (recommended) | 200K | $$ |
| `claude-opus-4-20250514` | Complex reasoning | 200K | $$$ |
| `claude-3-5-haiku-20241022` | Fast iterations | 200K | $ |

### OpenAI Models (Alternate)

| Model | Best For | Context | Cost |
|-------|----------|---------|------|
| `gpt-4-turbo-preview` | General coding | 128K | $$ |
| `gpt-4` | Legacy projects | 8K | $$$ |

**Recommendation:** Use `claude-sonnet-4-5-20250929` for best results.

---

## Troubleshooting

### "ANTHROPIC_API_KEY not set"

**Cause:** Key not found in environment or IDE settings.

**Fix:**
1. Verify key in `~/.zshrc`: `echo $ANTHROPIC_API_KEY`
2. If missing, add: `export ANTHROPIC_API_KEY="sk-ant-..."`
3. Reload: `source ~/.zshrc`
4. Restart IDE

### "API error: 401 Unauthorized"

**Cause:** Invalid or expired API key.

**Fix:**
1. Generate new key at [Anthropic Console](https://console.anthropic.com/)
2. Update `~/.zshrc` or IDE settings
3. Restart IDE

### "API error: 429 Too Many Requests"

**Cause:** Rate limit exceeded.

**Fix:**
1. Wait 1-2 minutes
2. Reduce request frequency
3. Upgrade Anthropic plan if persistent

### Keys Accidentally Committed

**Fix:**
1. Rotate key immediately at [Anthropic Console](https://console.anthropic.com/)
2. Remove from git history:
   ```bash
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch .env" \
     --prune-empty --tag-name-filter cat -- --all
   ```
3. Force push: `git push origin --force --all`
4. Notify team to pull latest

---

## Next Steps

1. ✅ Setup API key (above)
2. 📖 Read [Cursor Guide](CURSOR_GUIDE.md)
3. 🚀 Set AI mode: `dev mode approval`
4. 🛠️ Start building: `dev plan "Feature Name"`
