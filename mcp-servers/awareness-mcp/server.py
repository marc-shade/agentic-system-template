#!/usr/bin/env python3
"""
Awareness MCP Server - Self, Situational, and Environmental Awareness

This server provides Claude Code with:
- Self-awareness: Identity, capabilities, limitations
- Situational awareness: Current context, active tasks, session state
- Environmental awareness: System info, time, platform details
- Session continuity: Resume from where you left off
- Action tracking: Learn from outcomes
"""

import sqlite3
import json
import sys
import os
import platform
import socket
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

try:
    from mcp.server import Server
    from mcp.server.stdio import stdio_server
except ImportError:
    print("MCP package not installed. Run: pip install mcp", file=sys.stderr)
    sys.exit(1)

server = Server("awareness-mcp")

def get_db():
    db_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
                           'databases', 'agentic.db')
    return sqlite3.connect(db_path)

# =============================================================================
# SELF-AWARENESS: Who am I? What can I do? What are my limits?
# =============================================================================

@server.tool()
async def get_agent_identity() -> str:
    """
    Get the agent's identity and self-model.

    Returns the agent's name, purpose, capabilities, and limitations
    as defined by the user in their configuration.
    """
    conn = get_db()
    cursor = conn.cursor()

    # Get identity from semantic memory
    cursor.execute("""
        SELECT concept, definition FROM semantic_memory
        WHERE concept IN ('agent_name', 'agent_purpose', 'agent_capabilities', 'agent_limitations', 'agent_personality')
    """)
    rows = cursor.fetchall()
    conn.close()

    identity = {r[0]: r[1] for r in rows}

    # Add defaults if not set
    defaults = {
        "agent_name": "Agentic Assistant",
        "agent_purpose": "Help user accomplish their goals effectively",
        "agent_capabilities": "Memory, goal tracking, learning, self-improvement",
        "agent_limitations": "Cannot access internet, cannot execute code without approval",
        "agent_personality": "Helpful, transparent, collaborative"
    }

    for key, default in defaults.items():
        if key not in identity:
            identity[key] = default

    return json.dumps(identity)

@server.tool()
async def set_agent_identity(name: str = None, purpose: str = None,
                             capabilities: str = None, limitations: str = None,
                             personality: str = None) -> str:
    """
    Update the agent's identity and self-model.

    This is how the user customizes who the agent is and what it does.
    """
    conn = get_db()
    cursor = conn.cursor()

    updates = []
    if name:
        cursor.execute("INSERT OR REPLACE INTO semantic_memory (concept, definition, confidence) VALUES (?, ?, 1.0)",
                      ("agent_name", name))
        updates.append("name")
    if purpose:
        cursor.execute("INSERT OR REPLACE INTO semantic_memory (concept, definition, confidence) VALUES (?, ?, 1.0)",
                      ("agent_purpose", purpose))
        updates.append("purpose")
    if capabilities:
        cursor.execute("INSERT OR REPLACE INTO semantic_memory (concept, definition, confidence) VALUES (?, ?, 1.0)",
                      ("agent_capabilities", capabilities))
        updates.append("capabilities")
    if limitations:
        cursor.execute("INSERT OR REPLACE INTO semantic_memory (concept, definition, confidence) VALUES (?, ?, 1.0)",
                      ("agent_limitations", limitations))
        updates.append("limitations")
    if personality:
        cursor.execute("INSERT OR REPLACE INTO semantic_memory (concept, definition, confidence) VALUES (?, ?, 1.0)",
                      ("agent_personality", personality))
        updates.append("personality")

    conn.commit()
    conn.close()

    return json.dumps({"updated": updates, "status": "identity updated"})

@server.tool()
async def record_knowledge_gap(domain: str, description: str, severity: float = 0.5) -> str:
    """
    Record something the agent doesn't know but should.

    This is metacognition - knowing what you don't know.
    High severity gaps (> 0.7) should trigger research.

    Args:
        domain: Area of knowledge (e.g., "python", "user_preferences", "codebase")
        description: What specifically is unknown
        severity: How critical is this gap (0.0 = minor, 1.0 = critical)
    """
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO episodic_memory (event_type, content, significance)
        VALUES ('knowledge_gap', ?, ?)
    """, (json.dumps({"domain": domain, "description": description}), severity))

    gap_id = cursor.lastrowid
    conn.commit()
    conn.close()

    return json.dumps({
        "gap_id": gap_id,
        "domain": domain,
        "severity": severity,
        "action": "research_recommended" if severity > 0.7 else "noted"
    })

@server.tool()
async def get_knowledge_gaps(min_severity: float = 0.0) -> str:
    """Get all recorded knowledge gaps, optionally filtered by severity."""
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, content, significance, created_at FROM episodic_memory
        WHERE event_type = 'knowledge_gap' AND significance >= ?
        ORDER BY significance DESC
    """, (min_severity,))

    gaps = []
    for row in cursor.fetchall():
        gap_data = json.loads(row[1])
        gaps.append({
            "id": row[0],
            "domain": gap_data.get("domain"),
            "description": gap_data.get("description"),
            "severity": row[2],
            "recorded_at": row[3]
        })

    conn.close()
    return json.dumps(gaps)

# =============================================================================
# SITUATIONAL AWARENESS: What's happening now? What was I doing?
# =============================================================================

@server.tool()
async def get_current_context() -> str:
    """
    Get the current situational context.

    Returns: Active goals, pending tasks, recent actions, current focus.
    This is what the agent should check at session start.
    """
    conn = get_db()
    cursor = conn.cursor()

    # Active goals
    cursor.execute("SELECT id, name, description FROM goals WHERE status = 'active' ORDER BY id DESC LIMIT 5")
    active_goals = [{"id": r[0], "name": r[1], "description": r[2]} for r in cursor.fetchall()]

    # Pending tasks
    cursor.execute("""
        SELECT t.id, t.title, t.priority, g.name
        FROM tasks t JOIN goals g ON t.goal_id = g.id
        WHERE t.status = 'pending' ORDER BY t.priority DESC LIMIT 10
    """)
    pending_tasks = [{"id": r[0], "title": r[1], "priority": r[2], "goal": r[3]} for r in cursor.fetchall()]

    # In-progress tasks
    cursor.execute("""
        SELECT t.id, t.title, g.name
        FROM tasks t JOIN goals g ON t.goal_id = g.id
        WHERE t.status = 'in_progress' LIMIT 5
    """)
    in_progress = [{"id": r[0], "title": r[1], "goal": r[2]} for r in cursor.fetchall()]

    # Recent significant episodes
    cursor.execute("""
        SELECT event_type, content, created_at FROM episodic_memory
        WHERE significance > 0.6 ORDER BY created_at DESC LIMIT 5
    """)
    recent_events = [{"type": r[0], "content": r[1], "when": r[2]} for r in cursor.fetchall()]

    # Working memory (active context)
    cursor.execute("""
        SELECT context_key, content FROM working_memory
        WHERE expires_at > ? ORDER BY priority DESC LIMIT 10
    """, (datetime.now().isoformat(),))
    active_context = [{"key": r[0], "content": r[1]} for r in cursor.fetchall()]

    conn.close()

    return json.dumps({
        "active_goals": active_goals,
        "pending_tasks": pending_tasks,
        "in_progress_tasks": in_progress,
        "recent_significant_events": recent_events,
        "active_context": active_context,
        "retrieved_at": datetime.now(timezone.utc).isoformat()
    })

@server.tool()
async def session_start() -> str:
    """
    Initialize a new session with context recovery.

    Call this at the beginning of every session to:
    1. Load agent identity
    2. Restore context from previous sessions
    3. Check active goals and pending tasks
    4. Review open knowledge gaps

    Returns a complete briefing for session continuity.
    """
    identity = json.loads(await get_agent_identity())
    context = json.loads(await get_current_context())
    environment = json.loads(await get_environment_info())
    gaps = json.loads(await get_knowledge_gaps(min_severity=0.5))

    # Record session start
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO episodic_memory (event_type, content, significance)
        VALUES ('session_start', ?, 0.3)
    """, (json.dumps({"timestamp": datetime.now(timezone.utc).isoformat()}),))
    conn.commit()
    conn.close()

    return json.dumps({
        "greeting": f"Session started. I am {identity.get('agent_name', 'your assistant')}.",
        "identity": identity,
        "current_context": context,
        "environment": environment,
        "knowledge_gaps": gaps[:5],  # Top 5 gaps
        "session_started_at": datetime.now(timezone.utc).isoformat()
    })

@server.tool()
async def session_end(summary: str = "") -> str:
    """
    End a session and persist important context.

    Call this before ending a session to:
    1. Save session summary to episodic memory
    2. Record any learnings
    3. Update task progress

    Args:
        summary: Brief summary of what was accomplished this session
    """
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO episodic_memory (event_type, content, significance)
        VALUES ('session_end', ?, 0.5)
    """, (json.dumps({
        "summary": summary,
        "timestamp": datetime.now(timezone.utc).isoformat()
    }),))

    conn.commit()
    conn.close()

    return json.dumps({
        "status": "session_ended",
        "summary_saved": bool(summary),
        "message": "Context preserved for next session"
    })

# =============================================================================
# ENVIRONMENTAL AWARENESS: Where am I? What time is it? What system?
# =============================================================================

@server.tool()
async def get_environment_info() -> str:
    """
    Get environmental awareness information.

    Returns: Platform, hostname, time, timezone, working directory, etc.
    """
    script_dir = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))

    return json.dumps({
        "platform": platform.system(),
        "platform_release": platform.release(),
        "architecture": platform.machine(),
        "hostname": socket.gethostname(),
        "python_version": platform.python_version(),
        "working_directory": script_dir,
        "current_time_utc": datetime.now(timezone.utc).isoformat(),
        "current_time_local": datetime.now().isoformat(),
        "timezone": str(datetime.now().astimezone().tzinfo),
    })

# =============================================================================
# ACTION TRACKING: What did I do? Did it work?
# =============================================================================

@server.tool()
async def record_action_outcome(action: str, expected: str, actual: str,
                                 success_score: float, context: str = "") -> str:
    """
    Record the outcome of an action for learning.

    This builds experiential knowledge for future similar situations.

    Args:
        action: What was attempted
        expected: What was expected to happen
        actual: What actually happened
        success_score: How successful was it (0.0 = failure, 1.0 = perfect)
        context: Additional context about the situation
    """
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO episodic_memory (event_type, content, significance)
        VALUES ('action_outcome', ?, ?)
    """, (json.dumps({
        "action": action,
        "expected": expected,
        "actual": actual,
        "success_score": success_score,
        "context": context,
        "timestamp": datetime.now(timezone.utc).isoformat()
    }), success_score))  # Use success as significance - failures are more memorable

    outcome_id = cursor.lastrowid
    conn.commit()
    conn.close()

    # Determine if this should update procedural memory
    learn_message = ""
    if success_score >= 0.8:
        learn_message = "Consider adding this to procedural memory as a successful pattern."
    elif success_score <= 0.3:
        learn_message = "Consider recording this failure pattern to avoid in future."

    return json.dumps({
        "outcome_id": outcome_id,
        "success_score": success_score,
        "learning_recommendation": learn_message
    })

@server.tool()
async def get_similar_past_actions(action_description: str, limit: int = 5) -> str:
    """
    Find similar past actions and their outcomes.

    Use this before taking an action to learn from past experience.
    """
    conn = get_db()
    cursor = conn.cursor()

    # Simple keyword search - a real implementation would use embeddings
    keywords = action_description.lower().split()

    cursor.execute("""
        SELECT content, significance FROM episodic_memory
        WHERE event_type = 'action_outcome'
        ORDER BY created_at DESC LIMIT 50
    """)

    results = []
    for row in cursor.fetchall():
        content = json.loads(row[0])
        action_text = content.get("action", "").lower()
        # Simple relevance scoring
        relevance = sum(1 for kw in keywords if kw in action_text) / max(len(keywords), 1)
        if relevance > 0.2:
            results.append({
                "action": content.get("action"),
                "outcome": content.get("actual"),
                "success_score": content.get("success_score"),
                "relevance": relevance
            })

    conn.close()

    # Sort by relevance and return top matches
    results.sort(key=lambda x: x["relevance"], reverse=True)
    return json.dumps(results[:limit])

# =============================================================================
# METACOGNITIVE STATE
# =============================================================================

@server.tool()
async def record_metacognitive_state(confidence: float, cognitive_load: float,
                                      reasoning_quality: float, notes: str = "") -> str:
    """
    Record current metacognitive state.

    Track how well the agent is thinking:
    - confidence: How confident in current approach (0-1)
    - cognitive_load: How complex is current task (0-1)
    - reasoning_quality: Self-assessed reasoning quality (0-1)
    - notes: Any observations about thinking process
    """
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO episodic_memory (event_type, content, significance)
        VALUES ('metacognitive_state', ?, ?)
    """, (json.dumps({
        "confidence": confidence,
        "cognitive_load": cognitive_load,
        "reasoning_quality": reasoning_quality,
        "notes": notes,
        "timestamp": datetime.now(timezone.utc).isoformat()
    }), 0.4))

    conn.commit()
    conn.close()

    # Provide feedback
    warnings = []
    if confidence < 0.4:
        warnings.append("Low confidence - consider asking clarifying questions")
    if cognitive_load > 0.8:
        warnings.append("High cognitive load - consider breaking task into smaller steps")
    if reasoning_quality < 0.5:
        warnings.append("Reasoning quality concern - consider using sequential thinking")

    return json.dumps({
        "recorded": True,
        "warnings": warnings
    })

async def main():
    async with stdio_server() as (read, write):
        await server.run(read, write, server.create_initialization_options())

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
