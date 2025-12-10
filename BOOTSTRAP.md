# Bootstrap Instructions for Claude Code

**This file is for Claude Code (or other AI assistants) to follow when bootstrapping this template.**

## When User Says: "Bootstrap an agentic system from this repo"

Execute these steps in order:

### Step 1: Clone Repository
```bash
git clone https://github.com/marc-shade/agentic-system-template.git .
```

Or if already in a directory:
```bash
git clone https://github.com/marc-shade/agentic-system-template.git my-agentic-system
cd my-agentic-system
```

### Step 2: Run Bootstrap Script
```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

This will:
- Detect the user's platform (macOS/Linux/Windows)
- Create directory structure
- Install Python dependencies
- Initialize SQLite database
- Create MCP servers
- Configure Claude Code

### Step 3: Verify Installation
```bash
./scripts/health-check.sh
```

### Step 4: Customize System
Open `.claude/CLAUDE.md` and help the user fill in:
- System name
- Purpose
- User preferences
- Boundaries

### Step 5: Create First Goal
Ask the user what their first goal is, then:
```
Use the create_goal tool to create their first goal
```

### Step 6: Confirm Success
Tell the user:
- Their agentic system is ready
- How to access memory tools
- How to manage goals
- Where to find documentation

## Quick Verification Commands

After bootstrap, verify these work:
- `get_memory_status` - Should return counts for each memory tier
- `list_goals` - Should return empty list or first goal
- `get_next_task` - Should return "No pending tasks" or first task

## Troubleshooting

### "MCP package not installed"
```bash
source .venv/bin/activate
pip install mcp
```

### "Database not found"
```bash
./bootstrap.sh  # Re-run bootstrap
```

### "Permission denied"
```bash
chmod +x bootstrap.sh
chmod +x scripts/health-check.sh
```

## Post-Bootstrap Enhancements

Once basic system is working, offer to:
1. Add more MCP servers (learning-mcp, voice-mcp)
2. Set up monitoring
3. Configure backup automation
4. Add integrations (calendar, email, etc.)

---

*This document is read by AI assistants to help users bootstrap their agentic systems.*
