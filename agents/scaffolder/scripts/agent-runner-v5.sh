#!/bin/bash
#
# @scaffolder Agent Runner v5 - Production Hardening
# Enhanced reliability, metrics tracking, graceful fallback
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$AGENT_DIR/agent/skills/scaffold"

# Cross-platform timeout command
TIMEOUT_CMD="timeout"
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v gtimeout &> /dev/null; then
        TIMEOUT_CMD="gtimeout"
    else
        echo "⚠️  Warning: gtimeout not found. Install with: brew install coreutils"
        echo "    Continuing without timeout protection (may hang on long operations)."
        TIMEOUT_CMD=""
    fi
fi

# Source libraries with error handling
source "$SKILLS_DIR/lib/project-parser.sh" 2>/dev/null || {
    echo -e "${RED}[error]${NC} Failed to load project-parser.sh"
}
source "$SKILLS_DIR/lib/handoff-protocol.sh" 2>/dev/null || true
source "$SKILLS_DIR/lib/vector_memory_client_v2.sh" 2>/dev/null || true
source "$SKILLS_DIR/lib/component-injector.sh" 2>/dev/null || true

# Result tracking
START_TIME=$(date +%s)
INTELLIGENCE_CONTEXT=""
RETRIEVAL_METADATA=""
ERRORS=()
WARNINGS=()

# Enhanced logging with error tracking
log_info() { echo -e "${BLUE}[scaffolder]${NC} $1"; }
log_success() { echo -e "${GREEN}[scaffolder]${NC} $1"; }
log_error() { 
    echo -e "${RED}[scaffolder]${NC} $1" 
    ERRORS+=("$1")
}
log_warn() { 
    echo -e "${YELLOW}[scaffolder]${NC} $1" 
    WARNINGS+=("$1")
}
log_intelligence() { echo -e "${MAGENTA}[intelligence]${NC} $1"; }

# Progress bar
show_progress() {
    local step="$1" total="$2" message="$3"
    local width=30
    local filled=$((width * step / total))
    local empty=$((width - filled))
    printf "\r${BLUE}[scaffolder]${NC} ["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %d/%d %s" "$step" "$total" "$message"
    [[ "$step" -eq "$total" ]] && echo ""
}

# NEW: Robust vector memory query with fallback
query_intelligence_robust() {
    local project_type="$1"
    local features="$2"
    
    log_intelligence "Querying vector memory (production mode)..."
    
    # Build contextual query
    local query=""
    case "$project_type" in
        blog) query="blog content management markdown posts authentication" ;;
        dashboard) query="dashboard admin data visualization charts analytics" ;;
        api-service) query="API service REST endpoints routes middleware authentication" ;;
        *) query="project scaffolding $project_type best practices patterns" ;;
    esac
    
    # Add feature context
    [[ "$features" == *"user_authentication"* ]] && query="$query jwt security login register"
    [[ "$features" == *"database_integration"* ]] && query="$query prisma database models schema"
    [[ "$features" == *"markdown_support"* ]] && query="$query markdown react-markdown remark"
    
    # Query with new v3 client
    local result
    local metadata
    
    # Try v3 client first
    if command -v python3 &> /dev/null; then
        local query_output
        query_output=$(python3 /Users/rohitvashist/.openclaw/agents/shared/vector-memory/agent_query_v3.py "$query" 2>&1) || {
            log_warn "Vector Memory v3 query failed, falling back to v2"
            query_output=$(python3 /Users/rohitvashist/.openclaw/agents/shared/vector-memory/agent_query_v2.py "$query" 2>&1) || {
                log_warn "Vector Memory v2 also failed, continuing without context"
                RETRIEVAL_METADATA="{\"success\": false, \"fallback\": true}"
                return 1
            }
        }
        
        # Extract metadata from output
        local latency=$(echo "$query_output" | grep "Latency:" | awk '{print $2}')
        local success=$(echo "$query_output" | grep "Success:" | grep -q "✅" && echo "true" || echo "false")
        
        INTELLIGENCE_CONTEXT="$query_output"
        RETRIEVAL_METADATA="{\"latency_ms\": $latency, \"success\": $success, \"query\": \"$query\"}"
        
        if [[ "$success" == "true" ]]; then
            log_intelligence "Retrieved context in ${latency}ms"
        else
            log_warn "Context retrieval had issues, using defaults"
        fi
    else
        log_warn "Python not available, skipping Vector Memory"
        RETRIEVAL_METADATA="{\"success\": false, \"reason\": \"python_unavailable\"}"
        return 1
    fi
}

# NEW: Validate input
check_input() {
    local input="$1"
    
    # Check for empty input
    if [[ -z "$input" ]] || [[ "${#input}" -lt 3 ]]; then
        log_error "Project description too short (min 3 characters)"
        return 1
    fi
    
    # Check for suspicious characters
    if [[ "$input" =~ [\;\|\&\$\`\<\>] ]]; then
        log_error "Project description contains invalid characters"
        return 1
    fi
    
    return 0
}

# NEW: Validate environment
check_prerequisites() {
    local checks_passed=0
    local total_checks=4
    
    log_info "Checking prerequisites..."
    
    # Check Node.js
    if command -v node &> /dev/null; then
        local node_version=$(node --version)
        log_success "Node.js: $node_version"
        ((checks_passed++))
    else
        log_error "Node.js not found"
    fi
    
    # Check npm
    if command -v npm &> /dev/null; then
        local npm_version=$(npm --version)
        log_success "npm: $npm_version"
        ((checks_passed++))
    else
        log_error "npm not found"
    fi
    
    # Check templates directory
    if [[ -d "$SKILLS_DIR/templates" ]]; then
        local template_count=$(ls -1 "$SKILLS_DIR/templates" 2>/dev/null | wc -l)
        log_success "Templates: $template_count available"
        ((checks_passed++))
    else
        log_error "Templates directory not found"
    fi
    
    # Check Python (for Vector Memory)
    if command -v python3 &> /dev/null; then
        log_success "Python3: available"
        ((checks_passed++))
    else
        log_warn "Python3 not available (Vector Memory disabled)"
        ((checks_passed++))  # Don't fail on this
    fi
    
    echo ""
    return $((total_checks - checks_passed))
}

# Main create function with production hardening
run_create_production() {
    local input_description="$1"
    shift
    
    local use_github=false is_private=false custom_description="" output_dir="."
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --github) use_github=true; shift ;;
            --private) is_private=true; shift ;;
            --description) custom_description="$2"; shift 2 ;;
            --output-dir) output_dir="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
    
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  @scaffolder v5 - Production Hardened                        ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # NEW: Validate input
    if ! check_input "$input_description"; then
        log_error "Invalid input. Please provide a clear project description."
        return 1
    fi
    
    # NEW: Check prerequisites
    if ! check_prerequisites; then
        log_error "Prerequisites check failed. Please install missing dependencies."
        return 1
    fi
    
    # Phase 1: Parse and understand
    log_info "Analyzing project requirements..."
    
    local parsed_json
    if ! parsed_json=$(parse_project_request "$input_description" 2>/dev/null); then
        log_warn "Project parser failed, using fallback detection"
        parsed_json='{"project_type": "web-app", "suggested_template": "nextjs-fullstack", "features": []}'
    fi
    
    local project_type=$(echo "$parsed_json" | grep -o '"project_type": "[^"]*"' | cut -d'"' -f4)
    local suggested_template=$(echo "$parsed_json" | grep -o '"suggested_template": "[^"]*"' | cut -d'"' -f4)
    local features=$(echo "$parsed_json" | grep -o '"features": \[[^]]*\]' | cut -d'[' -f2 | cut -d']' -f1)
    
    log_success "Detected: $project_type → $suggested_template"
    
    # Phase 1.5: Robust Vector Memory query
    query_intelligence_robust "$project_type" "$features"
    
    # Phase 1.6: Generate actionable recommendations
    generate_actionable_recommendations "$project_type" "$features" "$INTELLIGENCE_CONTEXT"
    
    # Generate project name with validation
    local project_name=$(echo "$input_description" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-30)
    [[ -z "$project_name" ]] && project_name="my-project"
    
    # Validate template exists
    if [[ ! -d "$SKILLS_DIR/templates/$suggested_template" ]]; then
        log_warn "Template '$suggested_template' not found, using nextjs-fullstack"
        suggested_template="nextjs-fullstack"
        
        if [[ ! -d "$SKILLS_DIR/templates/$suggested_template" ]]; then
            log_error "No valid templates found"
            return 1
        fi
    fi
    
    # Phase 2-6: Generate with better error handling
    local total_steps=6
    local project_path="$output_dir/$project_name"
    
    # Create output directory
    mkdir -p "$output_dir" || {
        log_error "Cannot create output directory: $output_dir"
        return 1
    }
    
    # Clean up existing if needed
    if [[ -d "$project_path" ]]; then
        log_warn "Removing existing directory: $project_path"
        rm -rf "$project_path" || {
            log_error "Cannot remove existing directory"
            return 1
        }
    fi
    
    # Generate
    show_progress 2 "$total_steps" "Generating project..."
    mkdir -p "$project_path"
    
    if ! find "$SKILLS_DIR/templates/$suggested_template" -mindepth 1 -maxdepth 1 -exec cp -r {} "$project_path/" \; 2>/dev/null; then
        log_error "Failed to copy template files"
        return 1
    fi
    
    # P002: Inject feature components
    if [[ -n "$features" ]] && command -v inject_all_features &> /dev/null; then
        log_info "Injecting feature components..."
        inject_all_features "$features" "$project_path" || log_warn "Some feature injections failed"
    fi
    
    # Update package.json
    if [[ -f "$project_path/package.json" ]]; then
        if command -v jq &> /dev/null; then
            jq --arg name "$project_name" '.name = $name' "$project_path/package.json" > "$project_path/package.json.tmp" && \
                mv "$project_path/package.json.tmp" "$project_path/package.json"
        else
            log_warn "jq not available, package.json name not updated"
        fi
    fi
    
    # Install dependencies with timeout
    show_progress 3 "$total_steps" "Installing dependencies..."
    cd "$project_path"
    
    if ! ${TIMEOUT_CMD} 180 npm install --silent > /tmp/npm-install.log 2>&1; then
        log_error "npm install failed or timed out (3min)"
        return 1
    fi
    
    # Quality checks with individual error handling
    show_progress 4 "$total_steps" "Running quality checks..."
    local quality_score=0
    local quality_details=()
    
    # TypeScript
    if ${TIMEOUT_CMD} 60 npx tsc --noEmit > /tmp/tsc.log 2>&1; then
        quality_score=$((quality_score + 2))
        quality_details+=("TypeScript: PASS")
        log_success "TypeScript: PASS"
    else
        quality_details+=("TypeScript: FAIL")
        log_warn "TypeScript: FAIL (see /tmp/tsc.log)"
    fi
    
    # ESLint
    if ${TIMEOUT_CMD} 60 npx eslint src --ext .ts,.tsx --max-warnings 0 > /tmp/eslint.log 2>&1; then
        quality_score=$((quality_score + 2))
        quality_details+=("ESLint: PASS")
        log_success "ESLint: PASS"
    else
        quality_details+=("ESLint: FAIL")
        log_warn "ESLint: FAIL (see /tmp/eslint.log)"
    fi
    
    # Build
    if ${TIMEOUT_CMD} 120 npm run build > /tmp/build.log 2>&1; then
        quality_score=$((quality_score + 2))
        quality_details+=("Build: PASS")
        log_success "Build: PASS"
    else
        quality_details+=("Build: FAIL")
        log_warn "Build: FAIL (see /tmp/build.log)"
    fi
    
    # Structure
    if [[ -d "src" ]] || [[ -d "client/src" ]] || [[ -d "pages" ]]; then
        quality_score=$((quality_score + 2))
        quality_details+=("Structure: PASS")
        log_success "Structure: PASS"
    else
        quality_details+=("Structure: FAIL")
        log_warn "Structure: FAIL"
    fi
    
    # Dependencies
    if [[ -d "node_modules" ]] && [[ -n "$(ls -A node_modules 2>/dev/null | head -1)" ]]; then
        quality_score=$((quality_score + 2))
        quality_details+=("Dependencies: PASS")
        log_success "Dependencies: PASS"
    else
        quality_details+=("Dependencies: FAIL")
        log_warn "Dependencies: FAIL"
    fi
    
    # GitHub push (optional)
    show_progress 5 "$total_steps" "GitHub..."
    if [[ "$use_github" == true ]] && [[ -n "${GITHUB_TOKEN:-}" ]]; then
        if [[ -x "$SKILLS_DIR/scripts/github-push.sh" ]]; then
            "$SKILLS_DIR/scripts/github-push.sh" "$project_path" "$project_name" > /tmp/github-push.log 2>&1 || \
                log_warn "GitHub push failed (optional)"
        else
            log_warn "GitHub push script not available"
        fi
    else
        echo " skipped"
    fi
    
    # Finalize
    show_progress 6 "$total_steps" "Finalizing..."
    
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    
    # Save detailed result
    cat > "$project_path/.scaffold-result.json" << EOF
{
  "version": "5.0-production",
  "project": "$project_name",
  "type": "$project_type",
  "template": "$suggested_template",
  "quality": {
    "score": $quality_score,
    "details": $(printf '%s\n' "${quality_details[@]}" | jq -R . | jq -s .)
  },
  "intelligence": {
    "used": true,
    "metadata": $RETRIEVAL_METADATA
  },
  "errors": ${#ERRORS[@]},
  "warnings": ${#WARNINGS[@]},
  "duration_seconds": $duration,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    
    # Summary
    echo ""
    echo "========================================"
    echo "  ✨ Production-Ready Scaffolding Complete!"
    echo "========================================"
    echo ""
    echo "Project: $project_name"
    echo "Type: $project_type"
    echo "Quality: $quality_score/10"
    echo "Duration: ${duration}s"
    echo ""
    
    if [[ ${#ERRORS[@]} -gt 0 ]]; then
        echo "Errors: ${#ERRORS[@]}"
        for err in "${ERRORS[@]}"; do
            echo "  ❌ $err"
        done
        echo ""
    fi
    
    if [[ ${#WARNINGS[@]} -gt 0 ]]; then
        echo "Warnings: ${#WARNINGS[@]}"
        for warn in "${WARNINGS[@]}"; do
            echo "  ⚠️  $warn"
        done
        echo ""
    fi
    
    echo "Location: $project_path"
    echo ""
    echo "Next steps:"
    echo "  cd $project_name"
    echo "  npm run dev"
    echo ""
    
    # Return quality score as exit code for automation
    return $((10 - quality_score))
}

# Help
show_help() {
    cat << 'HELP'
@scaffolder v5 - Production Hardened

Usage:
  agent-runner-v5.sh "<project description>" [options]

Production Features:
  - Input validation
  - Prerequisite checks
  - Robust error handling
  - Timeout protection
  - Graceful fallbacks
  - Detailed metrics

Options:
  --github          Push to GitHub
  --private         Create private repository
  --description     Repository description
  --output-dir      Output directory (default: .)

Examples:
  agent-runner-v5.sh "create a blog with authentication"
  agent-runner-v5.sh "build an admin dashboard" --output-dir ./projects

HELP
}

# Main
main() {
    [[ $# -eq 0 ]] || [[ "$1" == "help" ]] || [[ "$1" == "--help" ]] && { show_help; exit 0; }
    run_create_production "$@"
}

main "$@"
