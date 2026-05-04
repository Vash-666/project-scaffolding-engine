#!/bin/bash
#
# @scaffolder Agent Runner v2 - Phase A Integrated
# CAP-001 + ARCH-001 + UX-001
#

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$AGENT_DIR/agent/skills/scaffold"

# Source libraries
source "$SKILLS_DIR/lib/project-parser.sh" 2>/dev/null || true
source "$SKILLS_DIR/lib/handoff-protocol.sh" 2>/dev/null || true

# Result tracking
RESULT_JSON=""
START_TIME=$(date +%s%3N)

# Logging with structured output support
LOG_BUFFER=""
log_info() { 
    echo -e "${BLUE}[scaffolder]${NC} $1"
    LOG_BUFFER="${LOG_BUFFER}INFO: $1\n"
}
log_success() { 
    echo -e "${GREEN}[scaffolder]${NC} $1"
    LOG_BUFFER="${LOG_BUFFER}SUCCESS: $1\n"
}
log_error() { 
    echo -e "${RED}[scaffolder]${NC} $1"
    LOG_BUFFER="${LOG_BUFFER}ERROR: $1\n"
}
log_warn() { 
    echo -e "${YELLOW}[scaffolder]${NC} $1"
    LOG_BUFFER="${LOG_BUFFER}WARN: $1\n"
}

# Show progress bar
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
        echo ""
    fi
}

# Initialize result
init_scaffolding_result() {
    RESULT_JSON=$(cat << 'JSON'
{
  "version": "2.0",
  "timestamp": "",
  "agent": "scaffolder",
  "status": "pending",
  "project": {
    "name": "",
    "template": "",
    "path": "",
    "parsed_type": "",
    "features": []
  },
  "quality": {
    "score": 0,
    "max_score": 10,
    "checks": {
      "typescript": { "passed": false, "points": 2 },
      "eslint": { "passed": false, "points": 2 },
      "build": { "passed": false, "points": 2 },
      "structure": { "passed": false, "points": 2 },
      "dependencies": { "passed": false, "points": 2 }
    }
  },
  "github": {
    "enabled": false,
    "repository_url": "",
    "visibility": "public"
  },
  "artifacts": [],
  "blockers": [],
  "next_steps": [],
  "logs": "",
  "duration_ms": 0,
  "error": null
}
JSON
)
}

# Update result field
update_result() {
    local field="$1"
    local value="$2"
    
    if command -v jq &> /dev/null; then
        RESULT_JSON=$(echo "$RESULT_JSON" | jq --arg f "$field" --arg v "$value" '.[$f] = $v')
    fi
}

# Main integration function
run_create_integrated() {
    local input_description="$1"
    shift
    
    local use_github=false
    local is_private=false
    local custom_description=""
    local output_dir="."
    
    # Parse remaining args
    while [[ $# -gt 0 ]]; do
        case $1 in
            --github) use_github=true; shift ;;
            --private) is_private=true; shift ;;
            --description) custom_description="$2"; shift 2 ;;
            --output-dir) output_dir="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
    
    # CAP-001: Parse natural language input
    log_info "Analyzing project requirements..."
    local parsed_json
    parsed_json=$(parse_project_request "$input_description")
    
    local project_type=$(echo "$parsed_json" | grep -o '"project_type": "[^"]*"' | cut -d'"' -f4)
    local suggested_template=$(echo "$parsed_json" | grep -o '"suggested_template": "[^"]*"' | cut -d'"' -f4)
    local features=$(echo "$parsed_json" | grep -o '"features": \[[^]]*\]' | cut -d'[' -f2 | cut -d']' -f1)
    
    log_success "Detected project type: $project_type"
    log_info "Suggested template: $suggested_template"
    log_info "Features: $features"
    
    # Generate project name from description
    local project_name=$(echo "$input_description" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-30)
    if [[ -z "$project_name" ]]; then
        project_name="my-project"
    fi
    
    # Initialize result
    init_scaffolding_result
    update_result "project.name" "$project_name"
    update_result "project.template" "$suggested_template"
    update_result "project.parsed_type" "$project_type"
    
    # Show recommendations
    echo ""
    log_info "Recommended customizations for $project_type:"
    generate_customizations "$parsed_json"
    echo ""
    
    # UX-001: Progress indicators for each phase
    local total_steps=5
    local current_step=0
    
    # Phase 1: Generate
    current_step=$((current_step + 1))
    show_progress "$current_step" "$total_steps" "Generating project..."
    
    local project_path="$output_dir/$project_name"
    mkdir -p "$output_dir"
    
    if [[ -d "$project_path" ]]; then
        log_warn "Project exists, removing..."
        rm -rf "$project_path"
    fi
    
    # Copy template
    mkdir -p "$project_path"
    find "$SKILLS_DIR/templates/$suggested_template" -mindepth 1 -maxdepth 1 -exec cp -r {} "$project_path/" \; 2>/dev/null || {
        log_error "Template not found: $suggested_template"
        update_result "status" "failed"
        update_result "error" "Template not found"
        return 1
    }
    
    # Update package.json
    if [[ -f "$project_path/package.json" ]]; then
        jq --arg name "$project_name" '.name = $name' "$project_path/package.json" > "$project_path/package.json.tmp" && \
            mv "$project_path/package.json.tmp" "$project_path/package.json"
    fi
    
    # Phase 2: Install
    current_step=$((current_step + 1))
    show_progress "$current_step" "$total_steps" "Installing dependencies..."
    
    cd "$project_path"
    if ! npm install --silent > /tmp/npm-install.log 2>&1; then
        log_error "npm install failed"
        update_result "status" "failed"
        update_result "error" "npm install failed"
        return 1
    fi
    
    # Phase 3: Quality checks
    current_step=$((current_step + 1))
    show_progress "$current_step" "$total_steps" "Running quality checks..."
    
    local quality_score=0
    
    # TypeScript
    if npx tsc --noEmit > /tmp/tsc.log 2>&1; then
        quality_score=$((quality_score + 2))
        log_success "TypeScript: PASS"
    else
        log_warn "TypeScript: FAIL"
    fi
    
    # ESLint
    if npx eslint src --ext .ts,.tsx --max-warnings 0 > /tmp/eslint.log 2>&1; then
        quality_score=$((quality_score + 2))
        log_success "ESLint: PASS"
    else
        log_warn "ESLint: FAIL"
    fi
    
    # Build
    if npm run build > /tmp/build.log 2>&1; then
        quality_score=$((quality_score + 2))
        log_success "Build: PASS"
    else
        log_warn "Build: FAIL"
    fi
    
    # Structure
    if [[ -d "src" ]] || [[ -d "client/src" ]]; then
        quality_score=$((quality_score + 2))
        log_success "Structure: PASS"
    else
        log_warn "Structure: FAIL"
    fi
    
    # Dependencies
    if [[ -d "node_modules" ]]; then
        quality_score=$((quality_score + 2))
        log_success "Dependencies: PASS"
    else
        log_warn "Dependencies: FAIL"
    fi
    
    update_result "quality.score" "$quality_score"
    
    # Phase 4: GitHub (optional)
    if [[ "$use_github" == true ]]; then
        current_step=$((current_step + 1))
        show_progress "$current_step" "$total_steps" "Pushing to GitHub..."
        
        if [[ -n "${GITHUB_TOKEN:-}" ]]; then
            # Run github push
            if "$SKILLS_DIR/scripts/github-push.sh" "$project_path" "$project_name" > /tmp/github-push.log 2>&1; then
                log_success "GitHub push complete"
                update_result "github.enabled" "true"
                update_result "github.repository_url" "https://github.com/${GITHUB_USERNAME:-user}/$project_name"
            else
                log_warn "GitHub push failed (see logs)"
            fi
        else
            log_warn "GITHUB_TOKEN not set, skipping GitHub push"
        fi
    else
        current_step=$((current_step + 1))
        show_progress "$current_step" "$total_steps" "Skipping GitHub..."
    fi
    
    # Phase 5: Finalize
    current_step=$((current_step + 1))
    show_progress "$current_step" "$total_steps" "Finalizing..."
    
    # Determine final status
    if [[ $quality_score -ge 9 ]]; then
        update_result "status" "success"
    elif [[ $quality_score -ge 6 ]]; then
        update_result "status" "partial"
    else
        update_result "status" "failed"
    fi
    
    # Add next steps
    if command -v jq &> /dev/null; then
        RESULT_JSON=$(echo "$RESULT_JSON" | jq '.next_steps += [{"action": "Start development", "command": "cd '"$project_name"' && npm run dev", "optional": false}]')
    fi
    
    # Calculate duration
    local end_time=$(date +%s)
    local duration=$(( (end_time - START_TIME / 1000) * 1000 ))
    update_result "duration_ms" "$duration"
    update_result "logs" "$LOG_BUFFER"
    
    # Print summary
    echo ""
    echo "========================================"
    echo "  Scaffolding Complete!"
    echo "========================================"
    echo ""
    echo "Project: $project_name"
    echo "Type: $project_type"
    echo "Quality Score: $quality_score/10"
    echo "Location: $project_path"
    echo "Duration: ${duration}ms"
    
    if [[ "$use_github" == true ]] && [[ -n "${GITHUB_TOKEN:-}" ]]; then
        echo "Repository: https://github.com/${GITHUB_USERNAME:-user}/$project_name"
    fi
    
    echo ""
    echo "Next steps:"
    echo "  cd $project_name"
    echo "  npm run dev"
    echo ""
    
    # Save result to file
    echo "$RESULT_JSON" > "$project_path/.scaffold-result.json"
    
    return 0
}

# Help
show_help() {
    cat << 'HELP'
@scaffolder v2 - Phase A (CAP-001 + ARCH-001 + UX-001)

Usage:
  agent-runner-v2.sh "<natural language description>" [options]

Examples:
  agent-runner-v2.sh "create a blog with user authentication" --github
  agent-runner-v2.sh "build an admin dashboard with database"
  agent-runner-v2.sh "create an api service" --github --private

Options:
  --github          Push to GitHub after generation
  --private         Create private repository
  --description     Repository description
  --output-dir      Output directory

Project Types Detected:
  - blog
  - dashboard
  - api-service

Features Detected:
  - authentication (auth, login, user)
  - database (database, db)
  - markdown (markdown, content)

HELP
}

# Main entry
main() {
    if [[ $# -eq 0 ]] || [[ "$1" == "help" ]] || [[ "$1" == "--help" ]]; then
        show_help
        exit 0
    fi
    
    # Run integrated create
    run_create_integrated "$@"
}

main "$@"
