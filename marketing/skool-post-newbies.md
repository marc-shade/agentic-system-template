# Skool Post: New to Claude Code? Here's How to Give It Superpowers

---

**Title:** New to Claude Code? Here's how to give it self-awareness, persistent memory, and goals in 60 seconds

---

I've been building with Claude Code for months now, and the #1 question I see from newcomers is:

**"How do I make Claude Code remember things between sessions?"**

And close behind:

**"Why does Claude Code forget who it is every time I restart?"**

The short answer: Claude Code has no native persistence or self-awareness.

The longer answer: **You can absolutely give it both** — with MCP servers.

But setting up MCP servers from scratch is a pain. You need to:
- Write the server code
- Configure the JSON
- Set up databases
- Wire everything together
- Debug why it's not loading...

I got tired of doing this every time I started a new project. So I built a template that does it all for you.

---

## One Command Setup

Open Claude Code in any directory and say:

```
Bootstrap an agentic system from https://github.com/marc-shade/agentic-system-template
```

That's it. Claude Code will:

1. Clone the template
2. Detect your platform (Mac/Linux/Windows)
3. Install Python dependencies
4. Create the database
5. Set up MCP servers
6. Configure everything automatically

**~60 seconds later**, you have an AI with:

- **Self-awareness** - knows its identity, capabilities, and limitations
- **Situational awareness** - knows what's happening, active goals, current context
- **Environmental awareness** - knows the platform, time, working directory
- **Persistent memory** that survives restarts
- **Goal tracking** that breaks big tasks into steps
- **Session continuity** - picks up exactly where you left off
- **Learning capabilities** that improve over time

---

## What You Actually Get

### Three Types of Awareness

| Type | What It Provides |
|------|------------------|
| **Self** | "I'm your coding assistant. I can write code but need approval for destructive actions." |
| **Situational** | "We're on task 2 of 5. Goal: Build REST API. Last action: defined endpoints." |
| **Environmental** | "Running on macOS, 2:30 PM local time, in ~/projects/my-app/" |

At session start, Claude automatically loads its identity, checks active goals, reviews what's pending, and orients itself. At session end, it preserves context for next time.

### 4-Tier Memory System

| Tier | What It's For | How Long It Lasts |
|------|---------------|-------------------|
| Working | Current task context | This session |
| Episodic | "Remember when we did X?" | Days to weeks |
| Semantic | Facts and knowledge | Permanent |
| Procedural | Skills and how-tos | Permanent |

### Goal Management

Tell Claude: *"I want to build a REST API"*

It automatically decomposes that into:
- Design endpoints
- Set up authentication
- Create database models
- Write tests

And tracks progress across sessions. Come back tomorrow, it knows where you left off.

### Self-Improvement

Every action outcome gets recorded. Patterns emerge. Claude learns what works in YOUR codebase, with YOUR preferences.

---

## Why This Matters

Without persistent memory, every Claude Code session starts from zero. You're constantly re-explaining:
- Your project structure
- Your coding preferences
- What you were working on
- What's already been tried

With this template, Claude Code becomes a **true collaborator** that grows with your project.

---

## The Philosophy Behind It

I call it **Collaborative Intelligence** — AI that amplifies humans rather than replacing them.

Key principles:
- **Human-in-the-loop**: You approve important decisions
- **Transparent**: Everything is logged and explainable
- **Your data**: Runs locally, you own everything
- **Progressive trust**: Start supervised, increase autonomy over time

---

## Get Started

**Option 1: One-liner** (recommended)
```
Bootstrap an agentic system from https://github.com/marc-shade/agentic-system-template
```

**Option 2: Manual**
```bash
git clone https://github.com/marc-shade/agentic-system-template.git my-project
cd my-project
./bootstrap.sh
claude .
```

---

## What's Next?

Once you've got the basics running, you can:
- Add more MCP servers (voice, workflows, external APIs)
- Connect to vector databases for semantic search
- Set up monitoring dashboards
- Build custom tools for your specific needs

The template is just the starting point. Make it yours.

---

**Link:** https://github.com/marc-shade/agentic-system-template

**License:** MIT (free to use, modify, share)

---

Drop a comment if you get it running — I'd love to hear what you build with it!

And if you hit any issues, open a GitHub issue. Happy to help newcomers get set up.

---

*Built by humans and AI, working together.*
