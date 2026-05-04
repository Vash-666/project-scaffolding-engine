#!/bin/bash
#
# @scaffolder Agent Runner
# Entry point for OpenClaw agent system
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging
log_info() { echo -e "${BLUE}[scaffolder]${NC} $1"; }
log_success() { echo -e "${GREEN}[scaffolder]${NC} $1"; }
log_error() { echo -e "${RED}[scaffolder]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[scaffolder]${NC} $1"; }

# Progress indicator
show_progress() {
    local step="$1"
    local total="$2"
    local message="$3"
    local width=30
    local filled=$((width * step / total))
    local empty=$((width - filled))
    
    printf "\r${BLUE}[scaffolder]${NC} ["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %d/%d %s" "$step" "$total" "$message"
    
    if [[ "$step" -eq "$total" ]]; then
        echo ""  # New line on complete
    fi
}

# Spinner for async operations
show_spinner() {
    local pid="$1"
    local message="$2"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r${BLUE}[scaffolder]${NC} ${spin:$i:1} %s" "$message"
        sleep 0.1
    done
    printf "\r"
}

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$AGENT_DIR/agent/skills/scaffold"

# Source handoff protocol
source "$SKILLS_DIR/lib/handoff-protocol.sh" 2>/dev/null || true

# Structured output mode
STRUCTURED_OUTPUT=false
RESULT_JSON=""

# Main entry point
main() {
    local command="$1"
    shift
    
    case "$command" in
        create)
            run_create "$@"
            ;;
        templates)
            run_templates
            ;;
        check)
            run_check
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Show help
show_help() {
    cat << 'HELP'
@scaffolder - Project Scaffolding Agent

Usage:
  agent-runner.sh <command> [options]

Commands:
  create <name> <template> [options]  Generate a new project
  templates                           List available templates
  check                               Validate setup
  help                                Show this help

Create Options:
  --github          Push to GitHub after generation
  --private         Create private repository (with --github)
  --description     Repository description
  --output-dir      Output directory

Examples:
  agent-runner.sh create my-app nextjs-fullstack
  agent-runner.sh create my-api express-react --github
  agent-runner.sh templates
  agent-runner.sh check

HELP
}

# Run create command
run_create() {
    local project_name=""
    local template=""
    local github_flag=""
    local private_flag=""
    local description=""
    local output_dir=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --github)
                github_flag="--github"
                shift
                ;;
            --private)
                private_flag="--private"
                shift
                ;;
            --description)
                description="--description $2"
                shift 2
                ;;
            --output-dir)
                output_dir="--output-dir $2"
                shift 2
                ;;
            -*)
                log_error "Unknown option: $1"
                exit 1
                ;;
            *)
                if [[ -z "$project_name" ]]; then
                    project_name="$1"
                elif [[ -z "$template" ]]; then
                    template="$1"
                else
                    log_error "Too many arguments"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Validate
    if [[ -z "$project_name" ]] || [[ -z "$template" ]]; then
        log_error "Project name and template are required"
        show_help
        exit 1
    fi
    
    # Run scaffold-and-push.sh
    log_info "Starting project scaffolding..."
    log_info "Project: $project_name"
    log_info "Template: $template"
    
    local scaffold_script="$SKILLS_DIR/scripts/scaffold-and-push.sh"
    
    if [[ ! -f "$scaffold_script" ]]; then
        log_error "Scaffold script not found: $scaffold_script"
        exit 1
    fi
    
    # Execute with all parsed options
    "$scaffold_script" $github_flag $private_flag $description $output_dir "$project_name" "$template"
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        # Record success in memory
        record_task "$project_name" "$template" "success"
    else
        record_task "$project_name" "$template" "failed"
    fi
    
    return $exit_code
}

# Run templates command
run_templates() {
    echo ""
    echo "Available Templates"
    echo "==================="
    echo ""
    
    local templates_dir="$SKILLS_DIR/templates"
    
    if [[ ! -d "$templates_dir" ]]; then
        log_error "Templates directory not found"
        exit 1
    fi
    
    echo -e "${CYAN}nextjs-fullstack${NC}"
    echo "  Next.js 14+ with TypeScript, Tailwind, Vitest"
    echo "  Quality: 10/10 ✅"
    echo ""
    
    echo -e "${CYAN}express-react${NC}"
    echo "  Express + React with npm workspaces"
    echo "  Quality: 10/10 ✅"
    echo ""
    
    echo "Use: create <project-name> <template>"
    echo ""
}

# Run check command
run_check() {
    echo ""
    echo "@scaffolder Setup Check"
    echo "======================="
    echo ""
    
    local all_ok=true
    
    # Check git
    if command -v git &> /dev/null; then
        echo -e "  ✅ Git: $(git --version | cut -d' ' -f3)"
    else
        echo -e "  ❌ Git: not found"
        all_ok=false
    fi
    
    # Check npm
    if command -v npm &> /dev/null; then
        echo -e "  ✅ npm: $(npm --version)"
    else
        echo -e "  ❌ npm: not found"
        all_ok=false
    fi
    
    # Check curl
    if command -v curl &> /dev/null; then
        echo -e "  ✅ curl: installed"
    else
        echo -e "  ❌ curl: not found"
        all_ok=false
    fi
    
    # Check jq
    if command -v jq &> /dev/null; then
        echo -e "  ✅ jq: $(jq --version)"
    else
        echo -e "  ❌ jq: not found (recommended)"
    fi
    
    # Check GitHub token
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        echo -e "  ✅ GITHUB_TOKEN: set"
    else
        echo -e "  ⚠️  GITHUB_TOKEN: not set (required for GitHub integration)"
    fi
    
    # Check templates
    local templates_dir="$SKILLS_DIR/templates"
    if [[ -d "$templates_dir/nextjs-fullstack" ]]; then
        echo -e "  ✅ Template: nextjs-fullstack"
    else
        echo -e "  ❌ Template: nextjs-fullstack missing"
        all_ok=false
    fi
    
    if [[ -d "$templates_dir/express-react" ]]; then
        echo -e "  ✅ Template: express-react"
    else
        echo -e "  ❌ Template: express-react missing"
        all_ok=false
    fi
    
    echo ""
    
    if [[ "$all_ok" == true ]]; then
        log_success "Setup check passed!"
    else
        log_warn "Some prerequisites missing. See above."
    fi
    
    echo ""
}

# Record task in memory
record_task() {
    local project_name="$1"
    local template="$2"
    local status="$3"
    
    local memory_file="$AGENT_DIR/MEMORY.md"
    local timestamp=$(date -Iseconds)
    
    # Create memory file if not exists
    if [[ ! -f "$memory_file" ]]; then
        cat > "$memory_file" << 'EOF'
# @scaffolder Memory

Recent scaffolding tasks.

EOF
    fi
    
    # Append task
    cat >> "$memory_file" << EOF

## $timestamp

- **Project:** $project_name
- **Template:** $template
- **Status:** $status

EOF
}

# Run main
main "$@"
