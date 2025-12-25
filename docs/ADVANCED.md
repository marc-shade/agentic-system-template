# Advanced Agentic Patterns

This document covers advanced patterns for building production-grade agentic systems.

## Table of Contents

1. [Memory Architecture](#memory-architecture)
2. [Orchestration Patterns](#orchestration-patterns)
3. [Quality Enforcement](#quality-enforcement)
4. [Anti-Hallucination](#anti-hallucination)
5. [Continuous Learning](#continuous-learning)

---

## Memory Architecture

### 4-Tier Memory System

The template includes a foundation for 4-tier memory:

| Tier | Purpose | Duration | Example |
|------|---------|----------|---------|
| **Working** | Active context | Session | Current task variables |
| **Episodic** | Experiences | Days-weeks | "Fixed bug in auth module" |
| **Semantic** | Knowledge | Permanent | "JWT tokens expire by default" |
| **Procedural** | Skills | Permanent | "Steps to deploy to production" |

### Holographic Memory (Advanced)

For production systems, consider implementing **Holographic Memory** - a spreading activation pattern:

```python
# Activation spreads across semantically related memories
# When you access "authentication", related concepts activate:
# - "JWT tokens" (0.8 activation)
# - "OAuth2" (0.7 activation)
# - "session management" (0.6 activation)
```

Key components:
1. **Activation Field**: Semantic spreading based on embedding similarity
2. **Memory-Influenced Routing**: Memory informs which model/approach to use
3. **Procedural Evolution**: Skills improve through experience tracking
4. **Routing Learning**: System learns optimal patterns over time

### Memory Versioning

Track changes to memories like git:

```python
# Create version commit
memory_commit(entity_name="project_config", message="Updated API endpoint")

# Create branch for experimentation
memory_branch(entity_name="algorithm", branch_name="experiment_1")

# Diff between versions
memory_diff(entity_name="project_config", version1=1, version2=3)

# Revert if needed
memory_revert(entity_name="project_config", version=2)
```

---

## Orchestration Patterns

### Relay Race Protocol

For complex multi-step workflows, use the **Relay Race Protocol** - 48-agent pipelines with structured handoffs:

```
[Researcher] → [Analyzer] → [Synthesizer] → [Validator] → [Formatter] → [Expert]
     ↓              ↓             ↓              ↓             ↓            ↓
  Research      Analyze       Combine        Verify        Polish      Finalize
  Context       Findings      Insights       Quality       Output      Delivery
```

Each "baton pass" includes:
- Quality score from previous step
- L-Score (provenance tracking)
- Output summary for next agent
- Token budget management

### Circuit Breaker Pattern

Prevent cascading failures with circuit breakers:

```
CLOSED (normal) → failures exceed threshold → OPEN (blocking)
                                                    ↓
                                              cooldown period
                                                    ↓
                                              HALF_OPEN (testing)
                                                    ↓
                                    success → CLOSED | failure → OPEN
```

Configuration per agent:
- `failure_threshold`: Failures before tripping (default: 5)
- `window_seconds`: Sliding window for failures (default: 60)
- `cooldown_seconds`: Time before recovery trial (default: 300)
- `fallback_agent`: Agent to use when circuit open

### Task Decomposition Strategies

| Strategy | Use Case |
|----------|----------|
| **Sequential** | Steps that depend on each other |
| **Parallel** | Independent tasks that can run concurrently |
| **Hierarchical** | Complex goals with sub-goals |

---

## Quality Enforcement

### Production-Only Policy

Never deliver:
- ❌ POCs (Proof of Concept)
- ❌ "Simple" versions
- ❌ Demo implementations
- ❌ Mock data
- ❌ Placeholder content
- ❌ Fake UI elements

Always deliver:
- ✅ Production-ready code
- ✅ Complete implementations
- ✅ Real integrations
- ✅ Live data only
- ✅ Proper error handling

### Ember Pattern (Quality Guardian)

Implement a "conscience keeper" that:
1. **Checks violations** before risky operations
2. **Provides feedback** on code quality
3. **Consults on decisions** with context-aware scoring
4. **Learns from corrections** to improve over time

```python
# Before writing code
ember_check_violation(
    action="Write",
    params={"file_path": "...", "content": "..."},
    context="implementing authentication"
)

# Get quality feedback
ember_get_feedback(timeframe="session")

# Learn from outcomes
ember_learn_from_outcome(
    action="implemented_feature",
    success=True,
    outcome="All tests passing"
)
```

---

## Anti-Hallucination

### Detection Patterns

Watch for hallucination indicators:
- Vague certainty ("I believe", "I think")
- Unsupported statistics
- Fabricated references
- Over-specific claims without sources

### L-Score (Provenance Tracking)

Calculate trustworthiness of derived knowledge:

```
L-Score = geometric_mean(confidence) × average(relevance) / depth_factor
```

Components:
- **Confidence**: How confident are we in each source?
- **Relevance**: How relevant is each source?
- **Depth**: How many derivation hops from original source?

Thresholds:
- `≥ 0.7`: High quality, trustworthy
- `0.3 - 0.7`: Review recommended
- `< 0.3`: Reject or verify manually

### Shadow Vector Search

Find contradicting evidence using inverted embeddings:

```python
# Regular search finds supporting evidence
# Shadow search (inverted embedding) finds contradictions

validate_claim(
    claim_text="Feature X improves performance by 50%",
    claim_embedding=embedding_vector,
    support_threshold=0.7,
    contradict_threshold=0.6
)
# Returns: credibility score, supporting evidence, contradictions
```

---

## Continuous Learning

### EWC++ (Elastic Weight Consolidation)

Prevent catastrophic forgetting when learning new tasks:

```python
# Record successful pattern
learn_from_correction(
    claim="Optimization approach X works for Y",
    original_confidence=0.6,
    corrected_confidence=0.9,
    provider_id="user_feedback",
    reasoning="Verified through testing"
)

# EWC++ preserves important knowledge while learning new
# Uses Fisher Information matrix to protect critical parameters
```

### ReasoningBank

Store and retrieve reasoning experiences:

```python
# Retrieve relevant past reasoning
rb_retrieve(query="authentication implementation", limit=5)

# Learn from task outcomes
rb_learn(
    task_id="task_123",
    query="implement JWT auth",
    outcome="success",
    trajectory="steps taken..."
)

# Periodically consolidate learnings
rb_consolidate()  # Deduplicates, detects contradictions
```

---

## Implementation Checklist

### Basic (Template Default)
- [x] 4-tier memory system
- [x] Session continuity
- [x] Goal and task tracking
- [x] Self-awareness foundation
- [x] Environmental awareness

### Intermediate
- [ ] Memory versioning (git-like)
- [ ] Circuit breaker for tools
- [ ] Production-only policy enforcement
- [ ] Basic hallucination detection

### Advanced
- [ ] Holographic memory with activation spreading
- [ ] Relay race protocol for complex workflows
- [ ] L-Score provenance tracking
- [ ] EWC++ continuous learning
- [ ] Shadow vector contradiction detection
- [ ] Semantic caching for queries

### Expert
- [ ] Multi-node cluster coordination
- [ ] Distributed task routing
- [ ] Cross-modal integration
- [ ] Autonomous improvement cycles
- [ ] Darwin-Gödel self-modification

---

## Related Projects

For production implementations of these patterns, see:

- [enhanced-memory-mcp](https://github.com/marc-shade/enhanced-memory-mcp) - Full 4-tier memory with Holographic features
- [agent-runtime-mcp](https://github.com/marc-shade/agent-runtime-mcp) - Relay Race and Circuit Breaker patterns
- [llm-council](https://github.com/marc-shade/llm-council) - Multi-LLM deliberation system

---

*These patterns emerge from real-world agentic system development. Start simple, add complexity as needed.*
