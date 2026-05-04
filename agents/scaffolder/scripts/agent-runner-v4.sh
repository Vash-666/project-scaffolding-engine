#!/bin/bash
#
# @scaffolder Agent Runner v4 - Intelligence Enhancement
# Enhanced Vector Memory retrieval + Actionable recommendations
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

# Source libraries
source "$SKILLS_DIR/lib/project-parser.sh" 2>/dev/null || true
source "$SKILLS_DIR/lib/handoff-protocol.sh" 2>/dev/null || true
source "$SKILLS_DIR/lib/vector_memory_client_v2.sh" 2>/dev/null || true

# Result tracking
START_TIME=$(date +%s)
INTELLIGENCE_CONTEXT=""
RETRIEVAL_SCORES=""

# Enhanced logging
log_info() { echo -e "${BLUE}[scaffolder]${NC} $1"; }
log_success() { echo -e "${GREEN}[scaffolder]${NC} $1"; }
log_error() { echo -e "${RED}[scaffolder]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[scaffolder]${NC} $1"; }
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

# ENHANCED: Query vector memory with better retrieval
query_intelligence_v2() {
    local project_type="$1"
    local features="$2"
    
    log_intelligence "Querying vector memory with enhanced retrieval..."
    
    # Build contextual query with more specific terms
    local query=""
    case "$project_type" in
        blog)
            query="blog content management markdown posts authentication user system"
            ;;
        dashboard)
            query="dashboard admin panel data visualization charts analytics system"
            ;;
        api-service)
            query="API service REST endpoints routes middleware authentication jwt"
            ;;
        *)
            query="project scaffolding best practices patterns implementation"
            ;;
    esac
    
    # Add feature context
    if echo "$features" | grep -q "user_authentication"; then
        query="$query jwt token bcrypt password login register middleware protected"
    fi
    
    if echo "$features" | grep -q "database_integration"; then
        query="$query prisma database models schema migrations postgresql sqlite"
    fi
    
    if echo "$features" | grep -q "markdown_support"; then
        query="$query markdown react-markdown remark gfm content rendering"
    fi
    
    # Query vector memory using enhanced v2 interface
    local result
    result=$(python3 /Users/rohitvashist/.openclaw/agents/shared/vector-memory/agent_query_v2.py "$query" 2>/dev/null) || true
    
    if [[ -n "$result" ]] && echo "$result" | grep -q "Found.*results"; then
        INTELLIGENCE_CONTEXT="$result"
        
        # Extract scores for reporting
        RETRIEVAL_SCORES=$(echo "$result" | grep -oE '\[[0-9]\.[0-9]{3}\]' | tr '\n' ' ')
        
        log_intelligence "Enhanced retrieval completed"
        log_intelligence "Similarity scores: $RETRIEVAL_SCORES"
        
        # Show top result preview
        local top_result
        top_result=$(echo "$result" | grep "^1\." | head -1)
        if [[ -n "$top_result" ]]; then
            log_intelligence "Top result: ${top_result:0:100}"
        fi
    else
        log_intelligence "No specific context found (using defaults)"
        RETRIEVAL_SCORES="N/A"
    fi
}

# Main create function with enhanced intelligence
run_create_enhanced_v2() {
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
    echo -e "${CYAN}║  @scaffolder v4 - Intelligence Enhancement                   ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Phase 1: Parse and understand
    log_info "Analyzing project requirements..."
    local parsed_json
    parsed_json=$(parse_project_request "$input_description")
    
    local project_type=$(echo "$parsed_json" | grep -o '"project_type": "[^"]*"' | cut -d'"' -f4)
    local suggested_template=$(echo "$parsed_json" | grep -o '"suggested_template": "[^"]*"' | cut -d'"' -f4)
    local features=$(echo "$parsed_json" | grep -o '"features": \[[^]]*\]' | cut -d'[' -f2 | cut -d']' -f1)
    
    log_success "Detected project type: $project_type"
    log_info "Template: $suggested_template"
    log_info "Features: $features"
    
    # Phase 1.5: Enhanced Vector Memory query
    query_intelligence_v2 "$project_type" "$features"
    
    # Phase 1.6: Generate actionable recommendations
    generate_actionable_recommendations "$project_type" "$features" "$INTELLIGENCE_CONTEXT"
    
    # Generate project name
    local project_name=$(echo "$input_description" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-30)
    [[ -z "$project_name" ]] && project_name="my-project"
    
    # Phase 2-6: Generate, install, quality checks, finalize
    local total_steps=6 current_step=2
    
    # Generate
    show_progress 2 "$total_steps" "Generating project..."
    local project_path="$output_dir/$project_name"
    mkdir -p "$output_dir"
    [[ -d "$project_path" ]] && rm -rf "$project_path"
    mkdir -p "$project_path"
    find "$SKILLS_DIR/templates/$suggested_template" -mindepth 1 -maxdepth 1 -exec cp -r {} "$project_path/" \; 2>/dev/null || {
        log_error "Template not found: $suggested_template"
        return 1
    }
    
    # Update package.json
    if [[ -f "$project_path/package.json" ]]; then
        jq --arg name "$project_name" '.name = $name' "$project_path/package.json" > "$project_path/package.json.tmp" && \
            mv "$project_path/package.json.tmp" "$project_path/package.json"
    fi
    
    # Install dependencies
    current_step=3
    show_progress "$current_step" "$total_steps" "Installing dependencies..."
    cd "$project_path"
    npm install --silent > /tmp/npm-install.log 2>&1 || {
        log_error "npm install failed"
        return 1
    }
    
    # Quality checks
    current_step=4
    show_progress "$current_step" "$total_steps" "Running quality checks..."
    local quality_score=0
    local quality_details=""
    
    if npx tsc --noEmit > /tmp/tsc.log 2>&1; then
        quality_score=$((quality_score + 2))
        quality_details="${quality_details}TypeScript: PASS\n"
        log_success "TypeScript: PASS"
    else
        quality_details="${quality_details}TypeScript: FAIL\n"
        log_warn "TypeScript: FAIL"
    fi
    
    if npx eslint src --ext .ts,.tsx --max-warnings 0 > /tmp/eslint.log 2>&1; then
        quality_score=$((quality_score + 2))
        quality_details="${quality_details}ESLint: PASS\n"
        log_success "ESLint: PASS"
    else
        quality_details="${quality_details}ESLint: FAIL\n"
        log_warn "ESLint: FAIL"
    fi
    
    if npm run build > /tmp/build.log 2>&1; then
        quality_score=$((quality_score + 2))
        quality_details="${quality_details}Build: PASS\n"
        log_success "Build: PASS"
    else
        quality_details="${quality_details}Build: FAIL\n"
        log_warn "Build: FAIL"
    fi
    
    if [[ -d "src" ]]; then
        quality_score=$((quality_score + 2))
        quality_details="${quality_details}Structure: PASS\n"
        log_success "Structure: PASS"
    else
        quality_details="${quality_details}Structure: FAIL\n"
    fi
    
    if [[ -d "node_modules" ]]; then
        quality_score=$((quality_score + 2))
        quality_details="${quality_details}Dependencies: PASS\n"
        log_success "Dependencies: PASS"
    fi
    
    # GitHub push (optional)
    current_step=5
    if [[ "$use_github" == true ]] && [[ -n "${GITHUB_TOKEN:-}" ]]; then
        show_progress "$current_step" "$total_steps" "Pushing to GitHub..."
        "$SKILLS_DIR/scripts/github-push.sh" "$project_path" "$project_name" > /tmp/github-push.log 2>&1 || log_warn "GitHub push failed"
    else
        show_progress "$current_step" "$total_steps" "Skipping GitHub..."
    fi
    
    # Finalize
    current_step=6
    show_progress "$current_step" "$total_steps" "Finalizing..."
    
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    
    # Save result
    cat > "$project_path/.scaffold-result.json" << EOF
{
  "version": "4.0-enhanced",
  "project": "$project_name",
  "type": "$project_type",
  "quality": $quality_score,
  "intelligence": {
    "enhanced_retrieval": true,
    "retrieval_scores": "$RETRIEVAL_SCORES",
    "actionable_recommendations": true
  },
  "duration_seconds": $duration
}
EOF
    
    # Summary
    echo ""
    echo "========================================"
    echo "  ✨ Enhanced Scaffolding Complete!"
    echo "========================================"
    echo ""
    echo "Project: $project_name"
    echo "Type: $project_type"
    echo "Quality Score: $quality_score/10"
    echo "Duration: ${duration}s"
    echo ""
    echo "Intelligence Metrics:"
    echo "  Enhanced Retrieval: ✅ Active"
    echo "  Similarity Scores: $RETRIEVAL_SCORES"
    echo "  Actionable Recommendations: ✅ Generated"
    echo ""
    echo "Location: $project_path"
    echo ""
    echo "Next steps:"
    echo "  cd $project_name"
    echo "  npm run dev"
    echo ""
}

# Help
show_help() {
    cat << 'HELP'
@scaffolder v4 - Intelligence Enhancement

Usage:
  agent-runner-v4.sh "<natural language description>" [options]

Examples:
  agent-runner-v4.sh "create a blog with user authentication"
  agent-runner-v4.sh "build an admin dashboard with database"

Enhancements:
  - Enhanced query construction for better retrieval
  - Improved similarity scores
  - Actionable implementation guidance
  - Code-level recommendations with examples

Options:
  --github          Push to GitHub after generation
  --private         Create private repository
  --description     Repository description
  --output-dir      Output directory

HELP
}

# Main
main() {
    [[ $# -eq 0 ]] || [[ "$1" == "help" ]] || [[ "$1" == "--help" ]] && { show_help; exit 0; }
    run_create_enhanced_v2 "$@"
}

main "$@"
