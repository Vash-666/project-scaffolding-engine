#!/bin/bash

# Quick Performance Test
# Runs 5 tests of each template to get performance metrics

echo "⚡ Quick Performance Test"
echo "========================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Arrays to store results
declare -a nextjs_times
declare -a express_times
declare -a nextjs_scores
declare -a express_scores

# Test Next.js (5 runs)
echo "Testing Next.js (5 runs)..."
for i in {1..5}; do
    echo "  Run $i:"
    TEST_DIR="/tmp/quick-nextjs-$i-$(date +%s)"
    
    # Generation
    START=$(date +%s)
    cd "$SCRIPT_DIR" && ./generate-project.sh "perf-nextjs-$i" nextjs-fullstack "$TEST_DIR" >/dev/null 2>&1
    GEN_TIME=$(( $(date +%s) - START ))
    
    # Validation
    START=$(date +%s)
    VAL_OUTPUT=$(cd "$SCRIPT_DIR" && ./validate-lightweight.sh "$TEST_DIR" nextjs-fullstack 2>&1)
    VAL_TIME=$(( $(date +%s) - START ))
    
    TOTAL_TIME=$((GEN_TIME + VAL_TIME))
    nextjs_times+=($TOTAL_TIME)
    
    # Get quality score
    SCORE=$(echo "$VAL_OUTPUT" | grep -E "Quality score: [0-9.]+" | sed 's/.*Quality score: //' | sed 's/\/10.*//' | head -1)
    if [ -n "$SCORE" ]; then
        nextjs_scores+=($SCORE)
    fi
    
    echo "    Time: ${TOTAL_TIME}s (gen: ${GEN_TIME}s, val: ${VAL_TIME}s)"
    echo "    Score: ${SCORE:-N/A}/10"
    
    # Cleanup
    rm -rf "$TEST_DIR" 2>/dev/null || true
done

echo ""

# Test Express+React (5 runs)
echo "Testing Express+React (5 runs)..."
for i in {1..5}; do
    echo "  Run $i:"
    TEST_DIR="/tmp/quick-express-$i-$(date +%s)"
    
    # Generation
    START=$(date +%s)
    cd "$SCRIPT_DIR" && ./generate-project.sh "perf-express-$i" express-react "$TEST_DIR" >/dev/null 2>&1
    GEN_TIME=$(( $(date +%s) - START ))
    
    # Validation
    START=$(date +%s)
    VAL_OUTPUT=$(cd "$SCRIPT_DIR" && ./validate-lightweight.sh "$TEST_DIR" express-react 2>&1)
    VAL_TIME=$(( $(date +%s) - START ))
    
    TOTAL_TIME=$((GEN_TIME + VAL_TIME))
    express_times+=($TOTAL_TIME)
    
    # Get quality score
    SCORE=$(echo "$VAL_OUTPUT" | grep -E "Quality score: [0-9.]+" | sed 's/.*Quality score: //' | sed 's/\/10.*//' | head -1)
    if [ -n "$SCORE" ]; then
        express_scores+=($SCORE)
    fi
    
    echo "    Time: ${TOTAL_TIME}s (gen: ${GEN_TIME}s, val: ${VAL_TIME}s)"
    echo "    Score: ${SCORE:-N/A}/10"
    
    # Cleanup
    rm -rf "$TEST_DIR" 2>/dev/null || true
done

echo ""
echo "========================"
echo "📊 Performance Summary"
echo ""

# Calculate statistics
function calculate_stats() {
    local times=("${!1}")
    local scores=("${!2}")
    local name="$3"
    
    if [ ${#times[@]} -eq 0 ]; then
        echo "No data for $name"
        return
    fi
    
    # Calculate average time
    local sum=0
    for t in "${times[@]}"; do
        sum=$((sum + t))
    done
    local avg_time=$((sum / ${#times[@]}))
    
    # Calculate P95 (simplified)
    local sorted_times=($(printf '%s\n' "${times[@]}" | sort -n))
    local p95_index=$(( (${#sorted_times[@]} * 95 + 99) / 100 - 1 ))
    local p95_time=${sorted_times[$p95_index]}
    
    # Calculate average score
    local score_sum=0
    local score_count=0
    for s in "${scores[@]}"; do
        score_sum=$(echo "$score_sum + $s" | bc)
        score_count=$((score_count + 1))
    done
    local avg_score="N/A"
    if [ $score_count -gt 0 ]; then
        avg_score=$(echo "scale=1; $score_sum / $score_count" | bc)
    fi
    
    echo "$name (n=${#times[@]}):"
    echo "  Average time: ${avg_time}s"
    echo "  P95 time: ${p95_time}s"
    echo "  Average quality: ${avg_score}/10"
    
    # Check against target
    if [ $p95_time -lt 120 ]; then
        echo "  ✅ P95 < 2 minutes: YES (${p95_time}s)"
    else
        echo "  ❌ P95 < 2 minutes: NO (${p95_time}s)"
    fi
    
    if [ "$avg_score" != "N/A" ] && (( $(echo "$avg_score >= 9.0" | bc -l) )); then
        echo "  ✅ Quality ≥9.0: YES (${avg_score}/10)"
    else
        echo "  ❌ Quality ≥9.0: NO (${avg_score}/10)"
    fi
    echo ""
}

calculate_stats nextjs_times[@] nextjs_scores[@] "Next.js"
calculate_stats express_times[@] express_scores[@] "Express+React"

echo "========================"
echo "🎯 Target: P95 < 2 minutes (120s), Quality ≥9.0/10"
echo ""
echo "✅ Performance testing complete"