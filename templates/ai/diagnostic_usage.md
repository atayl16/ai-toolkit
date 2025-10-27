# 🧠 Using the Diagnostic Recovery Prompt

## When to Use It

Use `ai_diagnose` when your AI coding assistant:
- Keeps applying the same fix in different files
- Patches symptoms instead of root cause
- Goes in circles without solving the bug
- Needs to step back and think systematically

## How to Use

### Option 1: Shell Command (Quick)
```bash
ai_diagnose
```

This opens the diagnostic prompt file.

### Option 2: In Cursor/Claude Chat
1. Run `cat ~/.ai-toolkit/prompts/diagnostic.prompt`
2. Copy the entire output
3. Paste into AI chat
4. Add your context: "We're stuck on [specific bug description]"

### Option 3: Direct Prompt
Simply say to the AI:

```
Stop editing code. We have a recurring bug with [description]. 
Switch to diagnostic-only mode:
1. Trace the data flow
2. Prove the contamination point
3. Classify the failure type
4. Propose ONE fix location
5. Wait for my approval before applying changes
```

## Real Example

**Bad approach (loops forever):**
```
AI: "I fixed the HTML escaping in the view"
You: "Still seeing HTML tags"
AI: "Let me fix it in the controller"
You: "Still broken"
AI: "Let me try the model..."
```

**Good approach (with diagnostic):**
```
You: "ai_diagnose - we're seeing HTML in job descriptions"

AI: "Stopping edits. Tracing data flow:
1. Fetcher gets raw HTML from API
2. JobPosting model saves it as-is
3. View renders without escaping
4. Problem: Raw HTML stored in DB
5. Fix location: Fetcher#parse_description
   - Strip HTML before saving
   - This is correct layer (data ingestion)
   
Waiting for approval before showing diff."

You: "Approved"

AI: [applies single fix in Fetcher with test]
```

## Why It Works

Forces the AI to:
1. **Stop** the fix loop
2. **Think** systematically
3. **Prove** the bug location
4. **Choose** one fix point
5. **Wait** for approval

This breaks the loop and finds the **root cause**.

## Add to Your Workflow

When starting a debugging session with AI, keep this ready:
```bash
alias debug="ai_diagnose"
```

Then when things get loopy: just type `debug` ⚡



