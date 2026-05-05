#!/bin/bash
#
# Handoff Protocol Validator — P003
# Validates HANDOFF.md exists and is complete before routing
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

validate_handoff() {
    local handoff_file="$1"
    local errors=0
    local warnings=0
    
    echo "==================================="
    echo "  Handoff Validation"
    echo "==================================="
    echo ""
    
    # Check file exists
    if [[ ! -f "$handoff_file" ]]; then
        echo -e "${RED}❌ FAIL${NC}: HANDOFF.md not found at $handoff_file"
        echo ""
        echo "Create handoff using template: agents/shared/templates/HANDOFF.md"
        return 1
    fi
    
    echo -e "${GREEN}✓${NC} File exists: $handoff_file"
    echo ""
    
    # Check required sections
    local required_sections=("Metadata" "Context Summary" "Artifacts" "Task Definition" "Acceptance Criteria" "Next Action")
    
    echo "Checking required sections..."
    for section in "${required_sections[@]}"; do
        if grep -q "## $section" "$handoff_file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $section"
        else
            echo -e "  ${RED}✗${NC} Missing: $section"
            ((errors++))
        fi
    done
    echo ""
    
    # Check acceptance criteria have checkboxes
    echo "Checking acceptance criteria..."
    if grep -qE "^\s*- \[ \]|^\s*- \[x\]" "$handoff_file" 2>/dev/null; then
        local checkbox_count=$(grep -cE "^\s*- \[ \]|^\s*- \[x\]" "$handoff_file")
        echo -e "  ${GREEN}✓${NC} Found $checkbox_count checkboxes"
    else
        echo -e "  ${RED}✗${NC} No checkboxes found in acceptance criteria"
        echo "    Add: - [ ] Criterion description"
        ((errors++))
    fi
    echo ""
    
    # Check due date exists
    echo "Checking due date..."
    if grep -qE "Due:.*[0-9]{4}-[0-9]{2}-[0-9]{2}|Due:.*immediate" "$handoff_file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Due date specified"
    else
        echo -e "  ${YELLOW}⚠${NC}  No due date found (recommended: add 'Due: YYYY-MM-DD')"
        ((warnings++))
    fi
    echo ""
    
    # Check for placeholder text
    echo "Checking for placeholder text..."
    local placeholders=0
    if grep -qE "\[TASK-ID\]|\[Source Agent\]|\[Target Agent\]|\[One sentence" "$handoff_file" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠${NC}  Template placeholders still present (not filled in)"
        ((warnings++))
    else
        echo -e "  ${GREEN}✓${NC} No obvious placeholders"
    fi
    echo ""
    
    # Summary
    echo "==================================="
    if [[ $errors -eq 0 ]]; then
        echo -e "${GREEN}✅ PASS${NC}: HANDOFF.md is valid"
        if [[ $warnings -gt 0 ]]; then
            echo -e "${YELLOW}⚠${NC}  $warnings warning(s) — review recommended"
        fi
        echo ""
        echo "Ready for agent routing."
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}: $errors validation error(s)"
        if [[ $warnings -gt 0 ]]; then
            echo -e "${YELLOW}⚠${NC}  $warnings warning(s)"
        fi
        echo ""
        echo "Fix errors before routing to agent."
        return 1
    fi
}

# Quick validation mode (exit codes only)
validate_handoff_quick() {
    local handoff_file="$1"
    
    # Required sections
    local required_sections=("Metadata" "Context Summary" "Artifacts" "Task Definition" "Acceptance Criteria" "Next Action")
    
    for section in "${required_sections[@]}"; do
        if ! grep -q "## $section" "$handoff_file" 2>/dev/null; then
            return 1
        fi
    done
    
    # Must have checkboxes
    if ! grep -qE "^\s*- \[ \]|^\s*- \[x\]" "$handoff_file" 2>/dev/null; then
        return 1
    fi
    
    return 0
}

# Create handoff from template
create_handoff() {
    local target_path="$1"
    local task_id="$2"
    
    if [[ -z "$target_path" || -z "$task_id" ]]; then
        echo "Usage: create_handoff <target_path> <task_id>"
        echo "Example: create_handoff ./HANDOFF.md P003-T1"
        return 1
    fi
    
    local template="/Users/rohitvashist/.openclaw/agents/shared/templates/HANDOFF.md"
    
    if [[ ! -f "$template" ]]; then
        echo "❌ Template not found: $template"
        return 1
    fi
    
    # Copy template and replace placeholder
    sed "s/\[TASK-ID\]/$task_id/g" "$template" > "$target_path"
    
    echo "✅ Created handoff template: $target_path"
    echo "   Task ID: $task_id"
    echo ""
    echo "Next: Fill in the template sections"
}

# Export functions for use in other scripts
export -f validate_handoff
export -f validate_handoff_quick
export -f create_handoff

# CLI usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        validate)
            if [[ -z "${2:-}" ]]; then
                echo "Usage: $0 validate <handoff_file>"
                exit 1
            fi
            validate_handoff "$2"
            exit $?
            ;;
        create)
            if [[ -z "${2:-}" || -z "${3:-}" ]]; then
                echo "Usage: $0 create <target_path> <task_id>"
                exit 1
            fi
            create_handoff "$2" "$3"
            ;;
        *)
            echo "Handoff Protocol Validator — P003"
            echo ""
            echo "Usage:"
            echo "  $0 validate <handoff_file>   - Validate existing handoff"
            echo "  $0 create <path> <task_id>   - Create handoff from template"
            echo ""
            echo "Examples:"
            echo "  $0 validate ./HANDOFF.md"
            echo "  $0 create ./P003-T1.md P003-T1"
            ;;
    esac
fi
