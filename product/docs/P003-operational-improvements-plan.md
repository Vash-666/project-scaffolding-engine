# P003: Operational Improvements Implementation Plan

**Status:** Draft — Awaiting Review  
**Priority:** Immediate (This Week)  
**Estimated Effort:** 2-3 hours  
**Impact:** High — Addresses root causes of multi-agent inefficiency

---

## Executive Summary

Based on assessment from all four agents (@product, @quality, @content, @scaffolder), we identified five core operational gaps:

1. **No structured handoff format** — Agents receive "dumping ground" tasks
2. **Tasks too broad** — Multi-week phases instead of 1-2 day sprints
3. **No persistent agent context** — Each spawn starts from scratch
4. **Quality is optional** — No mandatory verification gates
5. **Learning centralized** — No distributed agent journals

This plan implements the **top 3 highest-leverage fixes** identified by consensus.

---

## Phase 1: HANDOFF.md Template + Protocol

### Problem
Agents receive tasks with unclear context, fuzzy success criteria, and no standard format. The result: clarification loops, wasted time, inconsistent output.

### Solution
A single, enforced `HANDOFF.md` format that every agent-to-agent transition must use.

### Files to Create

#### 1. `templates/HANDOFF.md` (Template)
```markdown
# Handoff: [TASK-ID]

## Metadata
- **From:** [Source Agent or @switch]
- **To:** [Target Agent]
- **Created:** [YYYY-MM-DD HH:MM]
- **Due:** [YYYY-MM-DD HH:MM or "immediate"]

## Context Summary
[2-3 sentences: What was done before this handoff, what state we're in, why this task matters]

## Artifacts
- [ ] File/path to relevant code: `[path]`
- [ ] File/path to documentation: `[path]`
- [ ] Reference to previous handoff: `[HANDOFF-ID]`
- [ ] External links: `[url]`

## Task Definition
**Objective:** [One sentence — what needs to be accomplished]

**Scope:** 
- IN scope: [specific items]
- OUT of scope: [specific items to exclude]

**Constraints:**
- [Technical constraint, e.g., "use existing shadcn components only"]
- [Time constraint, e.g., "max 2 hours"]
- [Quality constraint, e.g., "must pass @quality review"]

## Acceptance Criteria (Definition of Done)
- [ ] Criterion 1: [Specific, verifiable, e.g., "File X exists at path Y"]
- [ ] Criterion 2: [Specific, verifiable, e.g., "All tests pass"]
- [ ] Criterion 3: [Specific, verifiable, e.g., "Quality score ≥ 8.5/10"]

## Next Action
[Exact first step the receiving agent should take — no ambiguity]

## Blockers
- [ ] None
- OR
- [ ] [Blocker description] — requires [action] from [agent]

## Notes
[Any additional context, warnings, or guidance]
```

#### 2. `agents/shared/handoff-protocol.sh` (Validation Script)
```bash
#!/bin/bash
#
# Handoff Protocol Validator — P003
# Validates HANDOFF.md exists and is complete before routing
#

validate_handoff() {
    local handoff_file="$1"
    local errors=0
    
    # Check file exists
    if [[ ! -f "$handoff_file" ]]; then
        echo "❌ FAIL: HANDOFF.md not found at $handoff_file"
        return 1
    fi
    
    # Check required sections
    local required_sections=("Metadata" "Context Summary" "Artifacts" "Task Definition" "Acceptance Criteria" "Next Action")
    
    for section in "${required_sections[@]}"; do
        if ! grep -q "## $section" "$handoff_file"; then
            echo "❌ FAIL: Missing section '$section'"
            ((errors++))
        fi
    done
    
    # Check acceptance criteria are checkable (have checkboxes)
    if ! grep -q "\- \[ \]" "$handoff_file"; then
        echo "❌ FAIL: No checkboxes found in Acceptance Criteria"
        ((errors++))
    fi
    
    # Check due date exists
    if ! grep -qE "Due:.*[0-9]{4}-[0-9]{2}-[0-9]{2}" "$handoff_file"; then
        echo "⚠️  WARN: No due date found (recommended: add 'Due: YYYY-MM-DD')"
    fi
    
    if [[ $errors -eq 0 ]]; then
        echo "✅ PASS: HANDOFF.md is valid"
        return 0
    else
        echo "❌ FAIL: $errors validation error(s)"
        return 1
    fi
}

# Usage: validate_handoff /path/to/HANDOFF.md
export -f validate_handoff
```

### Files to Modify

#### 3. `AGENTS.md` — Add Handoff Protocol Section
Add to **Session Startup** section:
```markdown
### Handoff Protocol (Mandatory)

**When spawning or routing to another agent:**

1. **Create HANDOFF.md** using template at `templates/HANDOFF.md`
2. **Validate** using `agents/shared/handoff-protocol.sh`
3. **Attach to spawn** — include path in task description
4. **Verify acceptance** — receiving agent must confirm criteria are clear

**No HANDOFF.md = No routing.** This is enforced at orchestration layer.
```

#### 4. `agents/shared/agent-router.py` — Add Validation
Add before routing logic:
```python
def route_to_agent(agent_id: str, task: str, handoff_path: str = None):
    """Route task to agent with mandatory handoff validation."""
    
    if not handoff_path:
        logger.error("Routing blocked: No HANDOFF.md provided")
        return {"status": "rejected", "reason": "Missing HANDOFF.md"}
    
    if not validate_handoff(handoff_path):
        logger.error(f"Routing blocked: Invalid HANDOFF.md at {handoff_path}")
        return {"status": "rejected", "reason": "Invalid HANDOFF.md"}
    
    # Proceed with routing...
```

### Enforcement Mechanism
- **Script validation:** `handoff-protocol.sh` runs before any spawn
- **AGENTS.md rule:** "No HANDOFF.md = No routing" — documented as mandatory
- **Router integration:** `agent-router.py` rejects spawn without valid handoff
- **Human override:** @switch can bypass with `--force` flag (logged)

### Time Estimate
- Template creation: 15 min
- Validation script: 30 min
- AGENTS.md update: 10 min
- Router integration: 30 min
- **Total: ~1.5 hours**

---

## Phase 2: 1-2 Day Sprint Format

### Problem
Projects scoped as "3 weeks, 6 agents, infinite scope" become monoliths. Agents can't deliver independently, @switch stays looped in.

### Solution
Every piece of work broken into sprints of exactly 1-2 days with single measurable deliverable.

### Files to Create

#### 5. `templates/SPRINT.md` (Template)
```markdown
# Sprint: [SPRINT-NAME]

## Metadata
- **Project:** [Project ID, e.g., P002]
- **Sprint Number:** [X of Y]
- **Duration:** [1 day | 2 days]
- **Dates:** [YYYY-MM-DD to YYYY-MM-DD]
- **Assigned Agent:** [@agent-name]

## Single Deliverable
**One sentence:** [What exactly will be delivered at sprint end]

**Why this matters:** [2 sentences on business/technical value]

## Definition of Done
- [ ] Deliverable exists at `[path]`
- [ ] Quality criteria met: [specific metric]
- [ ] Documentation updated: `[path]`
- [ ] Handoff to next agent ready (if applicable)

## Scope
**IN scope:**
- [Specific item 1]
- [Specific item 2]

**OUT of scope:**
- [Item that looks related but isn't]
- [Future work]

## Dependencies
- **Blocked by:** [None | SPRINT-X requires Y]
- **Blocks:** [None | SPRINT-Z waiting on this]

## Stop Conditions
**If any of these occur, escalate to @switch immediately:**
- Task takes >4 hours (scope creep)
- Acceptance criteria become unclear
- Dependencies not available
- Quality gate blocked

## Resources
- **Relevant files:** `[paths]`
- **Documentation:** `[links]`
- **Similar prior work:** `[reference]`

## Acceptance
**I confirm:**
- [ ] This sprint is completable in 1-2 days
- [ ] Acceptance criteria are specific and verifiable
- [ ] I understand what "done" looks like

**Agent:** _______________  **Date:** _______________
```

#### 6. `tools/sprint-validator.sh` (Validation Script)
```bash
#!/bin/bash
#
# Sprint Validator — P003
# Ensures sprints meet 1-2 day, single-deliverable criteria
#

validate_sprint() {
    local sprint_file="$1"
    local errors=0
    
    # Check file exists
    if [[ ! -f "$sprint_file" ]]; then
        echo "❌ FAIL: SPRINT.md not found"
        return 1
    fi
    
    # Check duration is 1-2 days
    if ! grep -qE "Duration.*(1 day|2 days)" "$sprint_file"; then
        echo "❌ FAIL: Sprint must be 1-2 days max"
        ((errors++))
    fi
    
    # Check single deliverable exists
    if ! grep -q "## Single Deliverable" "$sprint_file"; then
        echo "❌ FAIL: Missing 'Single Deliverable' section"
        ((errors++))
    fi
    
    # Check definition of done has checkboxes
    if ! grep -qE "- \[ \].*Deliverable exists" "$sprint_file"; then
        echo "❌ FAIL: Definition of Done missing deliverable checkbox"
        ((errors++))
    fi
    
    # Check stop conditions exist
    if ! grep -q "## Stop Conditions" "$sprint_file"; then
        echo "⚠️  WARN: Missing Stop Conditions section"
    fi
    
    if [[ $errors -eq 0 ]]; then
        echo "✅ PASS: Sprint is valid (1-2 days, single deliverable)"
        return 0
    else
        echo "❌ FAIL: $errors validation error(s)"
        return 1
    fi
}

export -f validate_sprint
```

### Files to Modify

#### 7. `AGENTS.md` — Add Sprint Rules
Add new section:
```markdown
## Sprint-Based Work (Mandatory)

**Rule:** No work proceeds without a validated SPRINT.md.

### Sprint Constraints
- **Duration:** Exactly 1-2 days
- **Deliverable:** Exactly ONE measurable thing
- **Assignment:** Exactly ONE agent (per sprint)

### Sprint Lifecycle
1. **Create** SPRINT.md from template
2. **Validate** with `tools/sprint-validator.sh`
3. **Assign** to agent with HANDOFF.md
4. **Execute** — agent works independently
5. **Review** — @quality checks deliverable
6. **Retro** — 5-minute retrospective (what worked/didn't)

### Stop Conditions (Escalate to @switch)
- Sprint takes >4 hours → scope creep detected
- Acceptance criteria unclear → need refinement
- Dependencies unavailable → blocked

### Multi-Sprint Projects
Break into sequence:
```
Project P002
├── Sprint 1: Foundation + Contact Form (Day 1-2)
├── Sprint 2: Authentication pages (Day 3-4)
├── Sprint 3: Data Table component (Day 5-6)
└── Sprint 4: Integration + Testing (Day 7)
```
Each sprint has its own SPRINT.md and HANDOFF.md.
```

#### 8. Update Existing Project Plans
Convert `P002-feature-coverage-implementation-plan.md`:
- Break 7 phases into 4 sprints
- Each sprint gets SPRINT.md
- Add HANDOFF.md for each agent assignment

### Enforcement Mechanism
- **Script validation:** `sprint-validator.sh` runs before any sprint starts
- **AGENTS.md rule:** "No SPRINT.md = No work" — documented as mandatory
- **Time box:** Hard stop at 2 days — forces decomposition
- **Retro requirement:** Sprint not complete without 5-minute retro

### Time Estimate
- Template creation: 15 min
- Validation script: 20 min
- AGENTS.md update: 15 min
- Convert existing project: 30 min
- **Total: ~1.5 hours**

---

## Phase 3: Agent Journals

### Problem
Agents have zero memory between activations. Each spawn starts from scratch with 70% truncated shared files.

### Solution
Each agent gets `agents/<name>/journal.md` — a running log of what they did, what they learned, what they'd do differently.

### Files to Create

#### 9. `agents/<name>/journal.md` (Per Agent)

Template for each agent:
```markdown
# @agent-name Journal

**Purpose:** Running log of work, learnings, and improvements for @agent-name.

---

## 2026-05-05: [Brief Task Description]

**Task:** [What I was asked to do]
**Sprint:** [Project/Sprint ID]
**Model Used:** [e.g., gemini-flash, sonnet]

### What I Did
- [Action 1]
- [Action 2]
- [Action 3]

### Result
- **Deliverable:** [What shipped]
- **Quality Score:** [If measured]
- **Time Taken:** [Actual vs estimated]

### What Worked
- [Pattern or approach that succeeded]

### What Didn't
- [Issue or surprise]

### What I'd Do Differently
- [Improvement for next time]

### Updated Rules
- [If this experience changed my AGENTS.md]

---

## [Previous Entry]
...
```

**Create for:**
- `agents/switch/journal.md`
- `agents/product/journal.md`
- `agents/quality/journal.md`
- `agents/content/journal.md`
- `agents/scaffolder/journal.md`

#### 10. `tools/journal-updater.sh` (Helper Script)
```bash
#!/bin/bash
#
# Journal Updater — P003
# Appends structured entry to agent journal
#

update_journal() {
    local agent_name="$1"
    local task="$2"
    local result="$3"
    local learnings="$4"
    
    local journal_file="agents/${agent_name}/journal.md"
    local date=$(date +%Y-%m-%d)
    
    # Create journal if doesn't exist
    if [[ ! -f "$journal_file" ]]; then
        echo "# @${agent_name} Journal" > "$journal_file"
        echo "" >> "$journal_file"
        echo "**Purpose:** Running log of work, learnings, and improvements." >> "$journal_file"
        echo "" >> "$journal_file"
        echo "---" >> "$journal_file"
        echo "" >> "$journal_file"
    fi
    
    # Append entry
    cat >> "$journal_file" << EOF

## ${date}: ${task}

**Task:** ${task}
**Result:** ${result}

### Key Learnings
${learnings}

---
EOF

    echo "✅ Updated journal: $journal_file"
}

# Usage: update_journal "content" "Quality Cut Showcase" "Created showcase, 9.8/10" "STAR framework worked well"
export -f update_journal
```

### Files to Modify

#### 11. `AGENTS.md` — Add Journal Protocol
Add to **Session Startup** section:
```markdown
### Agent Journal Protocol (Mandatory)

**Rule:** Every agent session ends with a journal entry.

**Location:** `agents/<name>/journal.md`

**Entry Format:**
- What I did (bullet list)
- Result (deliverable, quality, time)
- What worked (pattern/approach)
- What didn't (issue/surprise)
- What I'd do differently (improvement)

**Usage:**
- Journal is **append-only** — never delete old entries
- Journal is **loaded at spawn** — gives agent domain context
- Journal feeds **AGENTS.md updates** — patterns become rules

**Template:** Use `tools/journal-updater.sh` or manual entry.
```

#### 12. Update Agent Spawn Process
Modify spawn calls to include journal:
```bash
# Before spawning, load journal context
if [[ -f "agents/${agent_name}/journal.md" ]]; then
    journal_context=$(head -50 "agents/${agent_name}/journal.md")
    task="${task}

## Your Journal Context (Last 50 lines)
${journal_context}"
fi

# Spawn agent
sessions_spawn ...

# After completion, prompt for journal entry
read -p "Journal entry summary: " journal_summary
update_journal "$agent_name" "$task_brief" "$result" "$journal_summary"
```

### Enforcement Mechanism
- **AGENTS.md rule:** "Every session ends with journal entry"
- **Spawn integration:** Journal context loaded before task given
- **Completion check:** Journal entry required before task marked complete
- **Lightweight:** 5-minute entry, not a burden

### Time Estimate
- Create journal files (5 agents): 30 min
- Journal updater script: 20 min
- AGENTS.md update: 10 min
- Spawn integration: 20 min
- **Total: ~1.5 hours**

---

## Implementation Order

### Day 1 (Today): Handoff Protocol
1. ✅ Create `templates/HANDOFF.md` (15 min)
2. ✅ Create `agents/shared/handoff-protocol.sh` (30 min)
3. ✅ Update `AGENTS.md` with handoff rules (10 min)
4. ✅ Test with one agent spawn (15 min)

**Checkpoint:** HANDOFF.md validation works, blocks spawns without handoff

### Day 2: Sprint Format
5. ✅ Create `templates/SPRINT.md` (15 min)
6. ✅ Create `tools/sprint-validator.sh` (20 min)
7. ✅ Update `AGENTS.md` with sprint rules (15 min)
8. ✅ Convert P002 to sprint format (30 min)

**Checkpoint:** Existing project uses sprint format, validation passes

### Day 3: Agent Journals
9. ✅ Create `agents/<name>/journal.md` for all 5 agents (30 min)
10. ✅ Create `tools/journal-updater.sh` (20 min)
11. ✅ Update `AGENTS.md` with journal protocol (10 min)
12. ✅ Update spawn process to load/append journals (20 min)

**Checkpoint:** Journals exist, spawn loads journal context

### Day 4: Integration + Testing
13. ✅ Full workflow test: SPRINT → HANDOFF → Spawn → Journal (30 min)
14. ✅ Document in MEMORY.md (15 min)
15. ✅ Commit all changes to GitHub (15 min)

**Checkpoint:** End-to-end workflow validated, committed

---

## Success Metrics

| Metric | Before | After (Target) |
|--------|--------|----------------|
| Task clarity (agent survey) | 5/10 | 8/10 |
| Clarification rounds per task | 3-5 | 0-1 |
| Sprint completion rate | 60% | 90% |
| Quality gate pass rate | 70% | 90% |
| Agent context relevance | 30% | 80% |

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Overhead too high | Keep templates minimal; 5-min journal entries |
| Agents resist | Start with @switch enforcing; make value obvious |
| Templates become stale | Review monthly; update based on feedback |
| Retro becomes checkbox exercise | Keep to 5 minutes max; focus on one improvement |

---

## Open Questions

1. Should we implement agent-router.py enforcement now, or manual @switch validation first?
2. Should journals be limited to last N entries, or keep all history?
3. Should we retroactively populate journals for recent work?

---

## Next Steps After Approval

1. Review this plan with team
2. Create task assignments in `memory/2026-05-05.md`
3. Begin Day 1 implementation (Handoff Protocol)
4. Validate with @quality before proceeding to Day 2

---

**Plan Author:** @switch  
**Date:** 2026-05-05  
**Status:** Pending Approval
