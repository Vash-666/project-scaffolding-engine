#!/bin/bash
#
# Journal Updater — P003 Day 3
# Appends structured entry to agent journal
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base directory for agent journals
AGENTS_DIR="/Users/rohitvashist/.openclaw/agents"

# Create journal entry
update_journal() {
    local agent_name="$1"
    local task="$2"
    local result="$3"
    local worked="$4"
    local didnt="$5"
    local different="$6"
    
    local journal_file="${AGENTS_DIR}/${agent_name}/journal.md"
    local date=$(date +%Y-%m-%d)
    
    # Validate agent exists
    if [[ ! -d "${AGENTS_DIR}/${agent_name}" ]]; then
        echo -e "${RED}❌ Error${NC}: Agent '${agent_name}' not found"
        echo "   Expected: ${AGENTS_DIR}/${agent_name}/"
        return 1
    fi
    
    # Create journal if doesn't exist
    if [[ ! -f "$journal_file" ]]; then
        echo "# @${agent_name} Journal" > "$journal_file"
        echo "" >> "$journal_file"
        echo "**Purpose:** Running log of work, learnings, and improvements." >> "$journal_file"
        echo "" >> "$journal_file"
        echo "**Role:** [Agent role description]" >> "$journal_file"
        echo "" >> "$journal_file"
        echo "---" >> "$journal_file"
        echo "" >> "$journal_file"
        echo -e "${GREEN}✓${NC} Created new journal: $journal_file"
    fi
    
    # Append entry
    cat >> "$journal_file" << EOF

## ${date}: ${task}

**Task:** ${task}
**Result:** ${result}

### What Worked
${worked}

### What Didn't
${didnt}

### What I'd Do Differently
${different}

---
EOF

    echo -e "${GREEN}✓${NC} Updated journal for @${agent_name}"
    echo "   Entry: ${date}: ${task}"
}

# Interactive mode
update_journal_interactive() {
    local agent_name="$1"
    
    if [[ -z "$agent_name" ]]; then
        echo "Available agents:"
        ls -1 "$AGENTS_DIR" 2>/dev/null | grep -v "^shared$" | sed 's/^/  - /'
        echo ""
        read -p "Agent name: " agent_name
    fi
    
    echo ""
    echo "Journal Entry for @${agent_name}"
    echo "================================"
    echo ""
    
    read -p "Task brief (one line): " task
    read -p "Result (deliverable, quality, time): " result
    echo ""
    echo "What worked? (press Enter twice when done)"
    local worked=""
    while IFS= read -r line; do
        [[ -z "$line" ]] && break
        worked="${worked}- ${line}\n"
    done
    
    echo "What didn't? (press Enter twice when done)"
    local didnt=""
    while IFS= read -r line; do
        [[ -z "$line" ]] && break
        didnt="${didnt}- ${line}\n"
    done
    
    echo "What would you do differently? (press Enter twice when done)"
    local different=""
    while IFS= read -r line; do
        [[ -z "$line" ]] && break
        different="${different}- ${line}\n"
    done
    
    update_journal "$agent_name" "$task" "$result" "$worked" "$didnt" "$different"
}

# View recent journal entries
view_journal() {
    local agent_name="$1"
    local lines="${2:-50}"
    
    local journal_file="${AGENTS_DIR}/${agent_name}/journal.md"
    
    if [[ ! -f "$journal_file" ]]; then
        echo -e "${RED}❌ Error${NC}: No journal found for @${agent_name}"
        return 1
    fi
    
    echo "Journal: @${agent_name}"
    echo "========================"
    echo ""
    tail -n "$lines" "$journal_file"
}

# List all agents with journals
list_journals() {
    echo "Agent Journals"
    echo "=============="
    echo ""
    
    for agent_dir in "$AGENTS_DIR"/*/; do
        local agent_name=$(basename "$agent_dir")
        [[ "$agent_name" == "shared" ]] && continue
        
        local journal_file="${agent_dir}/journal.md"
        if [[ -f "$journal_file" ]]; then
            local entries=$(grep -c "^## " "$journal_file" 2>/dev/null || echo "0")
            local last_entry=$(grep "^## " "$journal_file" | tail -1 | sed 's/## //')
            echo -e "  ${GREEN}✓${NC} @${agent_name}: ${entries} entries"
            echo "    Last: ${last_entry}"
        else
            echo -e "  ${YELLOW}○${NC} @${agent_name}: No journal yet"
        fi
    done
}

# Export functions for use in other scripts
export -f update_journal
export -f update_journal_interactive
export -f view_journal
export -f list_journals

# CLI usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        update)
            if [[ -z "${2:-}" ]]; then
                echo "Usage: $0 update <agent_name> [task] [result] [worked] [didnt] [different]"
                echo "   or: $0 update <agent_name> (interactive mode)"
                exit 1
            fi
            if [[ $# -eq 2 ]]; then
                update_journal_interactive "$2"
            else
                update_journal "$2" "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-}"
            fi
            ;;
        view)
            if [[ -z "${2:-}" ]]; then
                echo "Usage: $0 view <agent_name> [lines]"
                exit 1
            fi
            view_journal "$2" "${3:-50}"
            ;;
        list)
            list_journals
            ;;
        *)
            echo "Journal Updater — P003 Day 3"
            echo ""
            echo "Commands:"
            echo "  update <agent> [args...]  - Add entry to agent journal"
            echo "  view <agent> [lines]      - View recent entries"
            echo "  list                      - List all agent journals"
            echo ""
            echo "Examples:"
            echo "  $0 update content "Created showcase" "9.8/10, 2hrs" "STAR worked" "Gemini failed" "Use DeepSeek""
            echo "  $0 update content (interactive)"
            echo "  $0 view content 30"
            echo "  $0 list"
            ;;
    esac
fi
