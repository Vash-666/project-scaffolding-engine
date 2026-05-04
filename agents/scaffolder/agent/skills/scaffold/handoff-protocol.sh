#!/bin/bash
#
# Structured Handoff Protocol - ARCH-001
# Standardized JSON result format for agent communication
#

# Initialize result structure
init_result() {
    cat << 'JSON'
{
  "version": "1.0",
  "timestamp": "",
  "agent": "scaffolder",
  "status": "pending",
  "project": {
    "name": "",
    "template": "",
    "path": ""
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
    "visibility": ""
  },
  "artifacts": [],
  "blockers": [],
  "next_steps": [],
  "duration_ms": 0,
  "error": null
}
JSON
}

# Set result field
set_result_field() {
    local json="$1"
    local field="$2"
    local value="$3"
    
    # Use jq if available, fallback to sed for simple fields
    if command -v jq &> /dev/null; then
        echo "$json" | jq --arg f "$field" --arg v "$value" '.[$f] = $v'
    else
        # Simple string replacement for basic fields
        echo "$json" | sed "s|\"$field\": \"[^\"]*\"|\"$field\": \"$value\"|"
    fi
}

# Set nested field with jq
set_nested_field() {
    local json="$1"
    local path="$2"
    local value="$3"
    
    if command -v jq &> /dev/null; then
        echo "$json" | jq --arg p "$path" --arg v "$value" 'setpath($p | split("."); $v)'
    else
        echo "$json"
    fi
}

# Add artifact
add_artifact() {
    local json="$1"
    local type="$2"
    local path="$3"
    local description="$4"
    
    if command -v jq &> /dev/null; then
        echo "$json" | jq --arg t "$type" --arg p "$path" --arg d "$description" \
            '.artifacts += [{"type": $t, "path": $p, "description": $d}]'
    else
        echo "$json"
    fi
}

# Add blocker
add_blocker() {
    local json="$1"
    local severity="$2"
    local message="$3"
    local suggestion="$4"
    
    if command -v jq &> /dev/null; then
        echo "$json" | jq --arg s "$severity" --arg m "$message" --arg sug "$suggestion" \
            '.blockers += [{"severity": $s, "message": $m, "suggestion": $sug}]'
    else
        echo "$json"
    fi
}

# Add next step
add_next_step() {
    local json="$1"
    local action="$2"
    local command="$3"
    local optional="${4:-false}"
    
    if command -v jq &> /dev/null; then
        echo "$json" | jq --arg a "$action" --arg c "$command" --argjson o "$optional" \
            '.next_steps += [{"action": $a, "command": $c, "optional": $o}]'
    else
        echo "$json"
    fi
}

# Mark quality check
mark_quality_check() {
    local json="$1"
    local check="$2"
    local passed="$3"
    
    if command -v jq &> /dev/null; then
        echo "$json" | jq --arg c "$check" --argjson p "$passed" \
            '.quality.checks[$c].passed = $p'
    else
        echo "$json"
    fi
}

# Calculate total quality score
calculate_quality_score() {
    local json="$1"
    
    if command -v jq &> /dev/null; then
        echo "$json" | jq '
            .quality.score = (
                (.quality.checks | to_entries | map(select(.value.passed) | .value.points) | add) // 0
            )
        '
    else
        echo "$json"
    fi
}

# Finalize result with timestamp and duration
finalize_result() {
    local json="$1"
    local start_time="$2"
    
    local end_time=$(date +%s%3N)
    local duration=$((end_time - start_time))
    local timestamp=$(date -Iseconds)
    
    if command -v jq &> /dev/null; then
        echo "$json" | jq --arg ts "$timestamp" --argjson dur "$duration" \
            '.timestamp = $ts | .duration_ms = $dur'
    else
        echo "$json"
    fi
}

# Pretty print result for display
print_result_summary() {
    local json="$1"
    
    if ! command -v jq &> /dev/null; then
        echo "$json"
        return
    fi
    
    local status=$(echo "$json" | jq -r '.status')
    local project_name=$(echo "$json" | jq -r '.project.name')
    local quality_score=$(echo "$json" | jq -r '.quality.score')
    local repo_url=$(echo "$json" | jq -r '.github.repository_url // ""')
    
    echo ""
    echo "========================================"
    echo "  Scaffolding Result"
    echo "========================================"
    echo ""
    echo "Status: $status"
    echo "Project: $project_name"
    echo "Quality Score: $quality_score/10"
    
    if [[ -n "$repo_url" ]]; then
        echo "Repository: $repo_url"
    fi
    
    # Quality checks breakdown
    echo ""
    echo "Quality Checks:"
    echo "$json" | jq -r '.quality.checks | to_entries | .[] | 
        if .value.passed then 
            "  ✅ \(.key): PASS (\(.value.points) pts)" 
        else 
            "  ❌ \(.key): FAIL" 
        end'
    
    # Blockers
    local blockers=$(echo "$json" | jq '.blockers | length')
    if [[ "$blockers" -gt 0 ]]; then
        echo ""
        echo "Blockers:"
        echo "$json" | jq -r '.blockers | .[] | "  ⚠️  \(.severity): \(.message)"'
    fi
    
    # Next steps
    local steps=$(echo "$json" | jq '.next_steps | length')
    if [[ "$steps" -gt 0 ]]; then
        echo ""
        echo "Next Steps:"
        echo "$json" | jq -r '.next_steps | .[] | 
            if .optional then
                "  ○ \(.action) (optional)"
            else
                "  → \(.action)"
            end'
    fi
    
    echo ""
}

# Export result to file
export_result() {
    local json="$1"
    local output_path="$2"
    
    echo "$json" > "$output_path"
}
