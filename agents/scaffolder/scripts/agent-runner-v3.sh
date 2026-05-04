#!/bin/bash
#
# @scaffolder Agent Runner v3 - Intelligence Integration
# Deep Vector Memory integration + improved understanding
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
source "$SKILLS_DIR/lib/vector_memory_client.sh" 2>/dev/null || true

# Result tracking
RESULT_JSON=""
START_TIME=$(date +%s)
INTELLIGENCE_CONTEXT=""

# Enhanced logging
LOG_BUFFER=""
log_info() { echo -e "${BLUE}[scaffolder]${NC} $1"; LOG_BUFFER="${LOG_BUFFER}INFO: $1\n"; }
log_success() { echo -e "${GREEN}[scaffolder]${NC} $1"; LOG_BUFFER="${LOG_BUFFER}SUCCESS: $1\n"; }
log_error() { echo -e "${RED}[scaffolder]${NC} $1"; LOG_BUFFER="${LOG_BUFFER}ERROR: $1\n"; }
log_warn() { echo -e "${YELLOW}[scaffolder]${NC} $1"; LOG_BUFFER="${LOG_BUFFER}WARN: $1\n"; }
log_intelligence() { echo -e "${MAGENTA}[intelligence]${NC} $1"; LOG_BUFFER="${LOG_BUFFER}INTEL: $1\n"; }

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

# NEW: Query vector memory for intelligence
query_intelligence() {
    local project_type="$1"
    local features="$2"
    
    log_intelligence "Querying vector memory for relevant context..."
    
    # Build contextual query based on project type
    local query=""
    case "$project_type" in
        blog)
            query="blog authentication content management best practices"
            ;;
        dashboard)
            query="dashboard admin data visualization patterns"
            ;;
        api-service)
            query="API service REST backend architecture patterns"
            ;;
        *)
            query="project scaffolding best practices patterns"
            ;;
    esac
    
    # Add feature context
    if echo "$features" | grep -q "user_authentication"; then
        query="$query authentication security"
    fi
    
    if echo "$features" | grep -q "database_integration"; then
        query="$query database models schema"
    fi
    
    # Query vector memory (suppress errors if not available)
    local context
    context=$(python3 /Users/rohitvashist/.openclaw/agents/shared/vector-memory/agent_query.py "$query" 2>/dev/null | grep -A2 "^\d\+\." | head -20) || true
    
    if [[ -n "$context" ]]; then
        INTELLIGENCE_CONTEXT="$context"
        log_intelligence "Retrieved relevant context from memory"
        echo "$context" | while read -r line; do
            [[ -n "$line" ]] && log_intelligence "  → ${line:0:80}"
        done
    else
        log_intelligence "No specific context found (using defaults)"
    fi
}

# NEW: Generate intelligence-aware recommendations
generate_smart_recommendations() {
    local project_type="$1"
    local features="$2"
    
    echo ""
    echo -e "${MAGENTA}┌────────────────────────────────────────────┐${NC}"
    echo -e "${MAGENTA}│  Intelligence-Aware Recommendations        │${NC}"
    echo -e "${MAGENTA}└────────────────────────────────────────────┘${NC}"
    echo ""
    
    # Base recommendations by type
    case "$project_type" in
        blog)
            echo "📄 Content Management:"
            echo "  • Add blog post schema with title, content, author, publishedAt"
            echo "  • Implement markdown rendering for posts"
            echo "  • Add RSS feed generation"
            ;;
        dashboard)
            echo "📊 Data Visualization:"
            echo "  • Add chart components (Line, Bar, Pie)"
            echo "  • Implement data table with sorting/filtering"
            echo "  • Add export to CSV/Excel functionality"
            ;;
        api-service)
            echo "⚡ API Architecture:"
            echo "  • Implement RESTful resource routing"
            echo "  • Add request validation middleware"
            echo "  • Include OpenAPI/Swagger documentation"
            ;;
    esac
    
    # Feature-specific recommendations
    if echo "$features" | grep -q "user_authentication"; then
        echo ""
        echo "🔐 Authentication Layer:"
        echo "  • Add JWT token-based auth"
        echo "  • Implement protected route middleware"
        echo "  • Add user registration/login flows"
        
        # Intelligence: suggest based on context
        if echo "$INTELLIGENCE_CONTEXT" | grep -qi "security"; then
            echo "  • ℹ️  Context suggests: Review security best practices from memory"
        fi
    fi
    
    if echo "$features" | grep -q "database_integration"; then
        echo ""
        echo "🗄️  Database Layer:"
        echo "  • Add ORM models for core entities"
        echo "  • Implement migration system"
        echo "  • Add database seeding for development"
    fi
    
    echo ""
}

# Main create function with intelligence integration
run_create_intelligent() {
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
    
    # Phase 1: Parse and understand (CAP-001 enhanced)
    log_info "Analyzing project requirements with intelligence..."
    local parsed_json
    parsed_json=$(parse_project_request "$input_description")
    
    local project_type=$(echo "$parsed_json" | grep -o '"project_type": "[^"]*"' | cut -d'"' -f4)
    local suggested_template=$(echo "$parsed_json" | grep -o '"suggested_template": "[^"]*"' | cut -d'"' -f4)
    local features=$(echo "$parsed_json" | grep -o '"features": \[[^]]*\]' | cut -d'[' -f2 | cut -d']' -f1)
    
    log_success "Detected project type: $project_type"
    log_info "Template: $suggested_template"
    log_info "Features: $features"
    
    # NEW: Phase 1.5: Query Vector Memory (ARCH-002 integration)
    query_intelligence "$project_type" "$features"
    
    # NEW: Generate smart recommendations
    generate_smart_recommendations "$project_type" "$features"
    
    # Generate project name
    local project_name=$(echo "$input_description" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-30)
    [[ -z "$project_name" ]] && project_name="my-project"
    
    # Phase 2-6: Generate, install, quality checks, GitHub, finalize
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
    
    npx tsc --noEmit > /tmp/tsc.log 2>&1 && quality_score=$((quality_score + 2)) && log_success "TypeScript: PASS"
    npx eslint src --ext .ts,.tsx --max-warnings 0 > /tmp/eslint.log 2>&1 && quality_score=$((quality_score + 2)) && log_success "ESLint: PASS"
    npm run build > /tmp/build.log 2>&1 && quality_score=$((quality_score + 2)) && log_success "Build: PASS"
    [[ -d "src" ]] && quality_score=$((quality_score + 2)) && log_success "Structure: PASS"
    [[ -d "node_modules" ]] && quality_score=$((quality_score + 2)) && log_success "Dependencies: PASS"
    
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
    
    # Save result
    cat > "$project_path/.scaffold-result.json" << EOF
{
  "version": "3.0-intelligent",
  "project": "$project_name",
  "type": "$project_type",
  "quality": $quality_score,
  "intelligence_used": true,
  "context_retrieved": $(if [[ -n "$INTELLIGENCE_CONTEXT" ]]; then echo "true"; else echo "false"; fi)
}
EOF
    
    # Summary
    echo ""
    echo "========================================"
    echo "  ✨ Intelligence-Aware Scaffolding Complete!"
    echo "========================================"
    echo ""
    echo "Project: $project_name"
    echo "Type: $project_type"
    echo "Quality Score: $quality_score/10"
    if [[ -n "$INTELLIGENCE_CONTEXT" ]]; then
        echo "Intelligence: Context-enhanced recommendations applied"
    fi
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
@scaffolder v3 - Intelligence Integration

Usage:
  agent-runner-v3.sh "<natural language description>" [options]

Examples:
  agent-runner-v3.sh "create a blog with user authentication" --github
  agent-runner-v3.sh "build an admin dashboard with database"

Intelligence Features:
  - Natural language understanding
  - Vector memory context retrieval
  - Smart recommendations based on project type
  - Context-aware feature suggestions

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
    run_create_intelligent "$@"
}

main "$@"
