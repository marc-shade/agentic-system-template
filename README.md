# Agentic System Template
<img width="300" height="300" alt="Agentic System Template" src="https://github.com/user-attachments/assets/e32f02a8-c7ae-4a1a-a48a-5a72c5a96442" align="right" />

**Bootstrap your own 24/7 autonomous AI system in minutes**

[![Claude Code](https://img.shields.io/badge/Built%20with-Claude%20Code-blueviolet)](https://claude.ai/code)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

**What Is This?**

A ready-to-use template for building your own **agentic AI system** - an autonomous AI that:

- **Knows itself** - identity, capabilities, and limitations (self-awareness)
- **Knows what's happening** - active context, tasks, and goals (situational awareness)
- **Knows its environment** - platform, time, location (environmental awareness)
- **Remembers everything** - 4-tier persistent memory across sessions
- **Manages goals** - task tracking that survives restarts
- **Learns and improves** - records outcomes, identifies gaps, optimizes over time

**Philosophy**: This template embodies *Collaborative Intelligence* - AI that amplifies human capabilities rather than replacing them.

---

## Quick Start (One Command)

Open Claude Code in a new project directory and say:

```
Bootstrap an agentic system from https://github.com/marc-shade/agentic-system-template
```

Claude Code will:
1. Clone this template
2. Detect your platform (macOS/Linux/Windows)
3. Install dependencies
4. Configure MCP servers
5. Initialize your memory system
6. Create your first goal

**That's it.** Your agentic system is running.

---

## Manual Installation

If you prefer step-by-step:

```bash
# 1. Clone the template
git clone https://github.com/marc-shade/agentic-system-template.git my-agentic-system
cd my-agentic-system

# 2. Run bootstrap
./bootstrap.sh

# 3. Open in Claude Code
claude .
```

---

## What You Get

### Core Components

| Component | Purpose |
|-----------|---------|
| **Awareness System** | Self, situational, and environmental awareness |
| **Memory System** | 4-tier memory (working, episodic, semantic, procedural) |
| **Goal Manager** | Persistent goals and task tracking |
| **Session Continuity** | Pick up where you left off with full context |
| **Self-Improvement** | Learn from outcomes, optimize over time |

### MCP Servers (Pre-configured)

| Server | Function |
|--------|----------|
| `awareness-mcp` | Identity, context, environment, metacognition |
| `memory-mcp` | Persistent memory with versioning |
| `goals-mcp` | Goal decomposition and task management |

### Directory Structure

```
my-agentic-system/
├── .claude/
│   └── CLAUDE.md           # System instructions (customize this!)
├── mcp-servers/
│   ├── awareness-mcp/      # Self/situational/environmental awareness
│   ├── memory-mcp/         # 4-tier memory system
│   └── goals-mcp/          # Goal and task management
├── databases/
│   └── agentic.db          # Your persistent data (auto-created)
├── scripts/
│   ├── health-check.sh     # System diagnostics
│   └── ...
├── bootstrap.sh            # Initial setup script
└── README.md               # This file
```

---

## Customization

### 1. Edit Your System Identity

Open `.claude/CLAUDE.md` and customize:

```markdown
# My Agentic System

## Identity
- Name: [Your AI's name]
- Purpose: [What it helps you with]
- Personality: [How it communicates]

## Capabilities
- [List what your system can do]

## Boundaries
- [What it should NOT do]
```

### 2. Add Your Own MCP Servers

Create a new server in `mcp-servers/`:

```python
# mcp-servers/my-server/server.py
from mcp.server import Server

server = Server("my-server")

@server.tool()
async def my_tool(param: str) -> str:
    """What this tool does."""
    return result
```

Add to `~/.claude.json`:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "python3",
      "args": ["mcp-servers/my-server/server.py"]
    }
  }
}
```

### 3. Connect External Services

The template supports easy integration with:
- **Databases**: SQLite (default), PostgreSQL, Redis
- **Vector Stores**: Qdrant, Chroma, Pinecone
- **Workflows**: Temporal, n8n, Make
- **Monitoring**: Prometheus, Grafana

See `docs/INTEGRATIONS.md` for guides.

### 4. Advanced Patterns

For production-grade systems, see `docs/ADVANCED.md`:

- **Holographic Memory**: Spreading activation across related concepts
- **Relay Race Protocol**: Multi-agent pipelines with structured handoffs
- **Circuit Breaker**: Prevent cascading failures
- **L-Score Provenance**: Track knowledge trustworthiness
- **Anti-Hallucination**: Detect and prevent AI fabrications
- **Continuous Learning**: EWC++ to prevent catastrophic forgetting

Related production implementations:
- [enhanced-memory-mcp](https://github.com/marc-shade/enhanced-memory-mcp)
- [agent-runtime-mcp](https://github.com/marc-shade/agent-runtime-mcp)

---

## Core Concepts

### Three Types of Awareness

| Type | What It Knows | Example |
|------|---------------|---------|
| **Self-Awareness** | Identity, capabilities, limitations | "I'm a coding assistant. I can read files but can't browse the web." |
| **Situational Awareness** | Active tasks, goals, conversation state | "We're working on Goal #3, task 2 of 5 is in progress." |
| **Environmental Awareness** | Platform, time, location, resources | "Running on macOS, 2:30 PM local time, in ~/projects/." |

### Memory Tiers

| Tier | Purpose | Duration |
|------|---------|----------|
| **Working** | Active context | Session |
| **Episodic** | Experiences | Days-weeks |
| **Semantic** | Knowledge | Permanent |
| **Procedural** | Skills | Permanent |

### Goal Decomposition

```
Goal: "Build a REST API"
  ├── Task: Design endpoints
  ├── Task: Implement authentication
  ├── Task: Add database models
  └── Task: Write tests
```

### Session Lifecycle

```
session_start()              ← Load identity, context, goals, gaps
    │
    ├── Work on tasks        ← Track progress, record outcomes
    ├── Learn from actions   ← Store experiences in memory
    ├── Identify gaps        ← Note what you don't know
    │
session_end()                ← Persist context for next time
```

### Learning Loop

```
Action → Outcome → Record → Pattern → Improve
   ↓        ↓        ↓         ↓          ↓
 Do it   Check   Store in   Extract   Apply next
        result   memory    insights     time
```

---

## Slash Commands

Once bootstrapped, these commands are available:

| Command | Function |
|---------|----------|
| `/status` | System health check |
| `/goals` | List active goals |
| `/memory` | Search memories |
| `/learn` | Record a learning |
| `/improve` | Run self-improvement cycle |

---

## Philosophy: Collaborative Intelligence

This template is built on the principle that **AGI should amplify humans, not replace them**.

Key design choices:
- **Human-in-the-loop**: Critical decisions require approval
- **Transparent reasoning**: All actions are logged and explainable
- **Open by default**: Your system, your data, your control
- **Progressive autonomy**: Start supervised, increase autonomy as trust builds

---

## Contributing

Found a bug? Have an improvement?

1. Fork this repository
2. Create your feature branch
3. Submit a pull request

We especially welcome:
- New MCP server templates
- Platform-specific improvements
- Documentation translations
- Integration guides

---

## Community

- **Discussions**: [GitHub Discussions](https://github.com/marc-shade/agentic-system-template/discussions)
- **Issues**: [Report bugs](https://github.com/marc-shade/agentic-system-template/issues)

---

## License

MIT License - Use freely, build amazing things.

---

## Acknowledgments

Built with:
- [Claude Code](https://claude.ai/code) - AI-powered development
- [Model Context Protocol](https://modelcontextprotocol.io/) - AI tool integration
- The open-source AI community

---

**Built by humans and AI, working together.**

*Part of the Collaborative Intelligence movement.*
