#!/bin/bash
# Agentic System Bootstrap Script
# Automatically sets up your agentic AI system

set -e

echo "================================================"
echo "  Agentic System Bootstrap"
echo "  Building your AI collaboration environment"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect platform
detect_platform() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

PLATFORM=$(detect_platform)
echo -e "${BLUE}Platform detected:${NC} $PLATFORM"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo -e "${BLUE}Installation directory:${NC} $SCRIPT_DIR"
echo ""

# Step 1: Check prerequisites
echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"

check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $1 found"
        return 0
    else
        echo -e "  ${RED}✗${NC} $1 not found"
        return 1
    fi
}

MISSING_DEPS=()

check_command "python3" || MISSING_DEPS+=("python3")
check_command "pip3" || MISSING_DEPS+=("pip3")
check_command "git" || MISSING_DEPS+=("git")

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}Missing dependencies: ${MISSING_DEPS[*]}${NC}"
    echo "Please install them and run this script again."
    exit 1
fi

echo -e "${GREEN}All prerequisites satisfied!${NC}"
echo ""

# Step 2: Create directory structure
echo -e "${YELLOW}Step 2: Creating directory structure...${NC}"

mkdir -p "$SCRIPT_DIR/databases"
mkdir -p "$SCRIPT_DIR/logs"
mkdir -p "$SCRIPT_DIR/mcp-servers/memory-mcp"
mkdir -p "$SCRIPT_DIR/mcp-servers/goals-mcp"
mkdir -p "$SCRIPT_DIR/docs"

echo -e "  ${GREEN}✓${NC} directories created"
echo ""

# Step 3: Install Python dependencies
echo -e "${YELLOW}Step 3: Installing Python dependencies...${NC}"

# Create virtual environment if it doesn't exist
if [ ! -d "$SCRIPT_DIR/.venv" ]; then
    python3 -m venv "$SCRIPT_DIR/.venv"
    echo -e "  ${GREEN}✓${NC} virtual environment created"
fi

# Activate and install
source "$SCRIPT_DIR/.venv/bin/activate"
pip install --quiet --upgrade pip
pip install --quiet mcp sqlite-utils

echo -e "  ${GREEN}✓${NC} dependencies installed"
echo ""

# Step 4: Initialize database
echo -e "${YELLOW}Step 4: Initializing database...${NC}"

python3 << 'PYEOF'
import sqlite3
import os

db_path = os.path.join(os.environ.get('SCRIPT_DIR', '.'), 'databases', 'agentic.db')
os.makedirs(os.path.dirname(db_path), exist_ok=True)

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Memory tables
cursor.execute('''
CREATE TABLE IF NOT EXISTS working_memory (
    id INTEGER PRIMARY KEY,
    context_key TEXT,
    content TEXT,
    priority INTEGER DEFAULT 5,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS episodic_memory (
    id INTEGER PRIMARY KEY,
    event_type TEXT,
    content TEXT,
    significance REAL DEFAULT 0.5,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS semantic_memory (
    id INTEGER PRIMARY KEY,
    concept TEXT UNIQUE,
    definition TEXT,
    confidence REAL DEFAULT 0.5,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS procedural_memory (
    id INTEGER PRIMARY KEY,
    skill_name TEXT UNIQUE,
    steps TEXT,
    success_rate REAL DEFAULT 0.5,
    execution_count INTEGER DEFAULT 0
)
''')

# Goals tables
cursor.execute('''
CREATE TABLE IF NOT EXISTS goals (
    id INTEGER PRIMARY KEY,
    name TEXT,
    description TEXT,
    status TEXT DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY,
    goal_id INTEGER,
    title TEXT,
    status TEXT DEFAULT 'pending',
    priority INTEGER DEFAULT 5,
    FOREIGN KEY (goal_id) REFERENCES goals(id)
)
''')

conn.commit()
conn.close()
print("  ✓ database initialized")
PYEOF

echo ""

# Step 5: Create MCP server configurations
echo -e "${YELLOW}Step 5: Configuring MCP servers...${NC}"

# Create minimal memory MCP server
cat > "$SCRIPT_DIR/mcp-servers/memory-mcp/server.py" << 'MCPEOF'
#!/usr/bin/env python3
"""Minimal Memory MCP Server for Agentic System Template."""

import sqlite3
import json
import sys
import os
from datetime import datetime, timedelta

# Add parent for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

try:
    from mcp.server import Server
    from mcp.server.stdio import stdio_server
except ImportError:
    print("MCP package not installed. Run: pip install mcp", file=sys.stderr)
    sys.exit(1)

server = Server("memory-mcp")

def get_db():
    db_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
                           'databases', 'agentic.db')
    return sqlite3.connect(db_path)

@server.tool()
async def add_to_working_memory(context_key: str, content: str, priority: int = 5, ttl_minutes: int = 60) -> str:
    """Add item to working memory (temporary, active context)."""
    conn = get_db()
    cursor = conn.cursor()
    expires_at = datetime.now() + timedelta(minutes=ttl_minutes)
    cursor.execute(
        "INSERT INTO working_memory (context_key, content, priority, expires_at) VALUES (?, ?, ?, ?)",
        (context_key, content, priority, expires_at.isoformat())
    )
    conn.commit()
    conn.close()
    return json.dumps({"status": "stored", "context_key": context_key})

@server.tool()
async def get_working_memory(context_key: str = None) -> str:
    """Get items from working memory."""
    conn = get_db()
    cursor = conn.cursor()
    if context_key:
        cursor.execute("SELECT * FROM working_memory WHERE context_key = ? AND expires_at > ?",
                      (context_key, datetime.now().isoformat()))
    else:
        cursor.execute("SELECT * FROM working_memory WHERE expires_at > ?",
                      (datetime.now().isoformat(),))
    rows = cursor.fetchall()
    conn.close()
    return json.dumps([{"id": r[0], "key": r[1], "content": r[2], "priority": r[3]} for r in rows])

@server.tool()
async def add_episode(event_type: str, content: str, significance: float = 0.5) -> str:
    """Add episode to episodic memory (experiences)."""
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO episodic_memory (event_type, content, significance) VALUES (?, ?, ?)",
        (event_type, content, significance)
    )
    episode_id = cursor.lastrowid
    conn.commit()
    conn.close()
    return json.dumps({"episode_id": episode_id, "status": "recorded"})

@server.tool()
async def add_concept(concept: str, definition: str, confidence: float = 0.5) -> str:
    """Add or update concept in semantic memory (knowledge)."""
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT OR REPLACE INTO semantic_memory (concept, definition, confidence) VALUES (?, ?, ?)",
        (concept, definition, confidence)
    )
    conn.commit()
    conn.close()
    return json.dumps({"concept": concept, "status": "stored"})

@server.tool()
async def search_memory(query: str, memory_type: str = "all") -> str:
    """Search across memory tiers."""
    conn = get_db()
    cursor = conn.cursor()
    results = []

    if memory_type in ["all", "episodic"]:
        cursor.execute("SELECT 'episodic', content FROM episodic_memory WHERE content LIKE ?",
                      (f"%{query}%",))
        results.extend([{"type": r[0], "content": r[1]} for r in cursor.fetchall()])

    if memory_type in ["all", "semantic"]:
        cursor.execute("SELECT 'semantic', concept, definition FROM semantic_memory WHERE concept LIKE ? OR definition LIKE ?",
                      (f"%{query}%", f"%{query}%"))
        results.extend([{"type": r[0], "concept": r[1], "definition": r[2]} for r in cursor.fetchall()])

    conn.close()
    return json.dumps(results)

@server.tool()
async def get_memory_status() -> str:
    """Get memory system status."""
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT COUNT(*) FROM working_memory WHERE expires_at > ?", (datetime.now().isoformat(),))
    working = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM episodic_memory")
    episodic = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM semantic_memory")
    semantic = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM procedural_memory")
    procedural = cursor.fetchone()[0]

    conn.close()
    return json.dumps({
        "working_memory": working,
        "episodic_memory": episodic,
        "semantic_memory": semantic,
        "procedural_memory": procedural,
        "total": working + episodic + semantic + procedural
    })

async def main():
    async with stdio_server() as (read, write):
        await server.run(read, write, server.create_initialization_options())

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
MCPEOF

echo -e "  ${GREEN}✓${NC} memory-mcp created"

# Create minimal goals MCP server
cat > "$SCRIPT_DIR/mcp-servers/goals-mcp/server.py" << 'MCPEOF'
#!/usr/bin/env python3
"""Minimal Goals MCP Server for Agentic System Template."""

import sqlite3
import json
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

try:
    from mcp.server import Server
    from mcp.server.stdio import stdio_server
except ImportError:
    print("MCP package not installed. Run: pip install mcp", file=sys.stderr)
    sys.exit(1)

server = Server("goals-mcp")

def get_db():
    db_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
                           'databases', 'agentic.db')
    return sqlite3.connect(db_path)

@server.tool()
async def create_goal(name: str, description: str = "") -> str:
    """Create a new goal."""
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO goals (name, description) VALUES (?, ?)", (name, description))
    goal_id = cursor.lastrowid
    conn.commit()
    conn.close()
    return json.dumps({"goal_id": goal_id, "name": name, "status": "created"})

@server.tool()
async def list_goals(status: str = "active") -> str:
    """List goals by status."""
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id, name, description, status FROM goals WHERE status = ?", (status,))
    goals = [{"id": r[0], "name": r[1], "description": r[2], "status": r[3]} for r in cursor.fetchall()]
    conn.close()
    return json.dumps(goals)

@server.tool()
async def create_task(goal_id: int, title: str, priority: int = 5) -> str:
    """Create a task for a goal."""
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO tasks (goal_id, title, priority) VALUES (?, ?, ?)",
                  (goal_id, title, priority))
    task_id = cursor.lastrowid
    conn.commit()
    conn.close()
    return json.dumps({"task_id": task_id, "title": title, "status": "created"})

@server.tool()
async def update_task_status(task_id: int, status: str) -> str:
    """Update task status (pending, in_progress, completed, blocked)."""
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("UPDATE tasks SET status = ? WHERE id = ?", (status, task_id))
    conn.commit()
    conn.close()
    return json.dumps({"task_id": task_id, "status": status})

@server.tool()
async def get_next_task() -> str:
    """Get the next task to work on (highest priority pending task)."""
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT t.id, t.title, t.priority, g.name as goal_name
        FROM tasks t
        JOIN goals g ON t.goal_id = g.id
        WHERE t.status = 'pending' AND g.status = 'active'
        ORDER BY t.priority DESC
        LIMIT 1
    """)
    row = cursor.fetchone()
    conn.close()
    if row:
        return json.dumps({"task_id": row[0], "title": row[1], "priority": row[2], "goal": row[3]})
    return json.dumps({"message": "No pending tasks"})

@server.tool()
async def complete_goal(goal_id: int) -> str:
    """Mark a goal as completed."""
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("UPDATE goals SET status = 'completed' WHERE id = ?", (goal_id,))
    cursor.execute("UPDATE tasks SET status = 'completed' WHERE goal_id = ?", (goal_id,))
    conn.commit()
    conn.close()
    return json.dumps({"goal_id": goal_id, "status": "completed"})

async def main():
    async with stdio_server() as (read, write):
        await server.run(read, write, server.create_initialization_options())

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
MCPEOF

echo -e "  ${GREEN}✓${NC} goals-mcp created"
echo ""

# Step 6: Configure Claude Code
echo -e "${YELLOW}Step 6: Configuring Claude Code...${NC}"

CLAUDE_CONFIG="$HOME/.claude.json"

# Check if claude.json exists
if [ -f "$CLAUDE_CONFIG" ]; then
    echo -e "  ${YELLOW}!${NC} Existing ~/.claude.json found"
    echo "  Add these MCP servers manually:"
    echo ""
    cat << CONFIGEOF
  "memory-mcp": {
    "command": "python3",
    "args": ["$SCRIPT_DIR/mcp-servers/memory-mcp/server.py"]
  },
  "goals-mcp": {
    "command": "python3",
    "args": ["$SCRIPT_DIR/mcp-servers/goals-mcp/server.py"]
  }
CONFIGEOF
else
    # Create new config
    cat > "$CLAUDE_CONFIG" << CONFIGEOF
{
  "mcpServers": {
    "memory-mcp": {
      "command": "python3",
      "args": ["$SCRIPT_DIR/mcp-servers/memory-mcp/server.py"]
    },
    "goals-mcp": {
      "command": "python3",
      "args": ["$SCRIPT_DIR/mcp-servers/goals-mcp/server.py"]
    }
  }
}
CONFIGEOF
    echo -e "  ${GREEN}✓${NC} ~/.claude.json created"
fi
echo ""

# Step 7: Create health check script
echo -e "${YELLOW}Step 7: Creating utilities...${NC}"

cat > "$SCRIPT_DIR/scripts/health-check.sh" << 'HEALTHEOF'
#!/bin/bash
# Health check for agentic system

echo "=== Agentic System Health Check ==="
echo ""

# Check database
if [ -f "databases/agentic.db" ]; then
    echo "✓ Database exists"
    sqlite3 databases/agentic.db "SELECT 'Working: ' || COUNT(*) FROM working_memory; SELECT 'Episodic: ' || COUNT(*) FROM episodic_memory; SELECT 'Semantic: ' || COUNT(*) FROM semantic_memory; SELECT 'Goals: ' || COUNT(*) FROM goals;"
else
    echo "✗ Database not found"
fi
echo ""

# Check MCP servers
echo "MCP Servers:"
for server in mcp-servers/*/server.py; do
    if [ -f "$server" ]; then
        name=$(dirname "$server" | xargs basename)
        echo "  ✓ $name"
    fi
done
echo ""

echo "=== Health Check Complete ==="
HEALTHEOF

chmod +x "$SCRIPT_DIR/scripts/health-check.sh"
echo -e "  ${GREEN}✓${NC} health-check.sh created"
echo ""

# Done!
echo "================================================"
echo -e "${GREEN}  Bootstrap Complete!${NC}"
echo "================================================"
echo ""
echo "Your agentic system is ready. Next steps:"
echo ""
echo "  1. Open this directory in Claude Code:"
echo "     ${BLUE}claude $SCRIPT_DIR${NC}"
echo ""
echo "  2. Customize your system identity:"
echo "     ${BLUE}Edit .claude/CLAUDE.md${NC}"
echo ""
echo "  3. Create your first goal:"
echo "     ${BLUE}Ask Claude to create a goal for you${NC}"
echo ""
echo "  4. Run health check:"
echo "     ${BLUE}./scripts/health-check.sh${NC}"
echo ""
echo "Documentation: $SCRIPT_DIR/docs/"
echo "Logs: $SCRIPT_DIR/logs/"
echo ""
echo -e "${GREEN}Welcome to Collaborative Intelligence!${NC}"
