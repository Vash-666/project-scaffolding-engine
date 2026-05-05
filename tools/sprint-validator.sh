#!/bin/bash
#
# Sprint Validator — P003 Day 2
# Ensures sprints meet 1-2 day, single-deliverable criteria
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

validate_sprint() {
    local sprint_file="$1"
    local errors=0
    local warnings=0
    
    echo "==================================="
    echo "  Sprint Validation"
    echo "==================================="
    echo ""
    
    # Check file exists
    if [[ ! -f "$sprint_file" ]]; then
        echo -e "${RED}❌ FAIL${NC}: SPRINT.md not found at $sprint_file"
        echo ""
        echo "Create sprint using template: agents/shared/templates/SPRINT.md"
        return 1
    fi
    
    echo -e "${GREEN}✓${NC} File exists: $sprint_file"
    echo ""
    
    # Check required sections
    local required_sections=("Metadata" "Single Deliverable" "Definition of Done" "Scope" "Stop Conditions")
    
    echo "Checking required sections..."
    for section in "${required_sections[@]}"; do
        if grep -q "## $section" "$sprint_file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $section"
        else
            echo -e "  ${RED}✗${NC} Missing: $section"
            ((errors++))
        fi
    done
    echo ""
    
    # Check duration is 1-2 days
    echo "Checking duration constraint..."
    if grep -qE "Duration.*(1 day|2 days)" "$sprint_file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Duration is 1-2 days"
    else
        echo -e "  ${RED}✗${NC} Duration must be exactly '1 day' or '2 days'"
        echo "    Fix: Change duration to '1 day' or '2 days'"
        ((errors++))
    fi
    echo ""
    
    # Check single deliverable is filled (not just header)
    echo "Checking single deliverable..."
    if grep -A 1 "## Single Deliverable" "$sprint_file" 2>/dev/null | grep -qv "## Single Deliverable\|^$"; then
        echo -e "  ${GREEN}✓${NC} Single deliverable specified"
    else
        echo -e "  ${RED}✗${NC} Single deliverable is empty"
        echo "    Add: One sentence describing the exact deliverable"
        ((errors++))
    fi
    echo ""
    
    # Check definition of done has checkboxes
    echo "Checking definition of done..."
    if grep -qE "^\s*- \[ \]|^\s*- \[x\]" "$sprint_file" 2>/dev/null; then
        local checkbox_count=$(grep -cE "^\s*- \[ \]|^\s*- \[x\]" "$sprint_file")
        echo -e "  ${GREEN}✓${NC} Found $checkbox_count checkboxes in DoD"
    else
        echo -e "  ${RED}✗${NC} Definition of Done missing checkboxes"
        echo "    Add: - [ ] Deliverable exists at \`path\`"
        ((errors++))
    fi
    echo ""
    
    # Check stop conditions exist and have specific triggers
    echo "Checking stop conditions..."
    if grep -q "## Stop Conditions" "$sprint_file" 2>/dev/null; then
        if grep -q ">4 hours\|4 hours" "$sprint_file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} Stop conditions include time box (4 hours)"
        else
            echo -e "  ${YELLOW}⚠${NC}  Stop conditions missing time box"
            echo "    Recommended: Add 'Task takes >4 hours' as stop condition"
            ((warnings++))
        fi
    else
        echo -e "  ${RED}✗${NC} Missing Stop Conditions section"
        ((errors++))
    fi
    echo ""
    
    # Check for placeholder text
    echo "Checking for placeholder text..."
    if grep -qE "\[SPRINT-NAME\]|\[Project ID\]|\[One sentence\]|\[Specific item" "$sprint_file" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠${NC}  Template placeholders still present (not filled in)"
        ((warnings++))
    else
        echo -e "  ${GREEN}✓${NC} No obvious placeholders"
    fi
    echo ""
    
    # Summary
    echo "==================================="
    if [[ $errors -eq 0 ]]; then
        echo -e "${GREEN}✅ PASS${NC}: Sprint is valid (1-2 days, single deliverable)"
        if [[ $warnings -gt 0 ]]; then
            echo -e "${YELLOW}⚠${NC}  $warnings warning(s) — review recommended"
        fi
        echo ""
        echo "Ready for agent assignment."
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}: $errors validation error(s)"
        if [[ $warnings -gt 0 ]]; then
            echo -e "${YELLOW}⚠${NC}  $warnings warning(s)"
        fi
        echo ""
        echo "Fix errors before assigning to agent."
        return 1
    fi
}

# Quick validation mode (exit codes only)
validate_sprint_quick() {
    local sprint_file="$1"
    
    # Check file exists
    [[ ! -f "$sprint_file" ]] && return 1
    
    # Check duration
    grep -qE "Duration.*(1 day|2 days)" "$sprint_file" 2>/dev/null || return 1
    
    # Check single deliverable
    grep -q "## Single Deliverable" "$sprint_file" 2>/dev/null || return 1
    
    # Check definition of done has checkboxes
    grep -qE "^\s*- \[ \]|^\s*- \[x\]" "$sprint_file" 2>/dev/null || return 1
    
    # Check stop conditions
    grep -q "## Stop Conditions" "$sprint_file" 2>/dev/null || return 1
    
    return 0
}

# Create sprint from template
create_sprint() {
    local target_path="$1"
    local sprint_name="$2"
    
    if [[ -z "$target_path" || -z "$sprint_name" ]]; then
        echo "Usage: create_sprint <target_path> <sprint_name>"
        echo "Example: create_sprint ./SPRINT.md 'P003-S1-Handoff'"
        return 1
    fi
    
    local template="/Users/rohitvashist/.openclaw/agents/shared/templates/SPRINT.md"
    
    if [[ ! -f "$template" ]]; then
        echo "❌ Template not found: $template"
        return 1
    fi
    
    # Copy template and replace placeholder
    sed "s/\[SPRINT-NAME\]/$sprint_name/g" "$template" > "$target_path"
    
    echo "✅ Created sprint template: $target_path"
    echo "   Sprint name: $sprint_name"
    echo ""
    echo "Next: Fill in the template sections"
    echo "Required:"
    echo "  - Duration (1 day or 2 days)"
    echo "  - Single deliverable (one sentence)"
    echo "  - Definition of Done (checkboxes)"
    echo "  - Stop conditions (>4 hours rule)"
}

# Estimate sprint complexity
estimate_sprint() {
    local sprint_file="$1"
    
    if [[ ! -f "$sprint_file" ]]; then
        echo "❌ Sprint file not found"
        return 1
    fi
    
    echo "Sprint Estimation"
    echo "================="
    echo ""
    
    # Extract deliverable
    local deliverable=$(grep -A 1 "## Single Deliverable" "$sprint_file" | grep -v "##" | head -1 | xargs)
    echo "Deliverable: $deliverable"
    echo ""
    
    # Check scope size
    local in_scope_count=$(grep -A 10 "IN scope:" "$sprint_file" | grep "^- " | wc -l)
    echo "IN scope items: $in_scope_count"
    
    # Check dependencies
    if grep -q "Blocked by: None" "$sprint_file" 2>/dev/null; then
        echo "Dependencies: None (ready to start)"
    else
        echo "Dependencies: Has blockers — review required"
    fi
    echo ""
    
    # Duration check
    local duration=$(grep "Duration:" "$sprint_file" | sed 's/.*Duration: //')
    echo "Duration: $duration"
    echo ""
    
    # Risk assessment
    if [[ $in_scope_count -gt 5 ]]; then
        echo "⚠️  Warning: Many scope items ($in_scope_count) — consider splitting"
    fi
    
    if [[ -z "$deliverable" || "$deliverable" == "[What exactly"* ]]; then
        echo "❌ Deliverable not defined — fill in before starting"
    fi
}

# Export functions for use in other scripts
export -f validate_sprint
export -f validate_sprint_quick
export -f create_sprint
export -f estimate_sprint

# CLI usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        validate)
            if [[ -z "${2:-}" ]]; then
                echo "Usage: $0 validate <sprint_file>"
                exit 1
            fi
            validate_sprint "$2"
            exit $?
            ;;
        create)
            if [[ -z "${2:-}" || -z "${3:-}" ]]; then
                echo "Usage: $0 create <target_path> <sprint_name>"
                exit 1
            fi
            create_sprint "$2" "$3"
            ;;
        estimate)
            if [[ -z "${2:-}" ]]; then
                echo "Usage: $0 estimate <sprint_file>"
                exit 1
            fi
            estimate_sprint "$2"
            ;;
        *)
            echo "Sprint Validator — P003 Day 2"
            echo ""
            echo "Commands:"
            echo "  validate <file>   - Validate sprint meets 1-2 day criteria"
            echo "  create <path> <name> - Create sprint from template"
            echo "  estimate <file>   - Estimate sprint complexity"
            echo ""
            echo "Examples:"
            echo "  $0 validate ./SPRINT.md"
            echo "  $0 create ./P003-S1.md 'P003-S1-Handoff'"
            echo "  $0 estimate ./SPRINT.md"
            ;;
    esac
fi
