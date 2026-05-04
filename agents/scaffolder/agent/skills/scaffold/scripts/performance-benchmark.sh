#!/bin/bash

# Performance Benchmark for @scaffolder
# Runs 20 tests (10 Next.js + 10 Express+React) and analyzes performance

echo "⚡ Performance Benchmark - @scaffolder"
echo "======================================"
echo ""
echo "Target: P95 < 2 minutes (120 seconds) for complete scaffolding"
echo "Tests: 20 runs (10 Next.js + 10 Express+React)"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_FILE="/tmp/scaffold-performance-$(date +%Y%m%d-%H%M%S).csv"

# Create results file
echo "test_number,template_type,generation_ms,validation_ms,total_ms,file_count,quality_score" > "$RESULTS_FILE"

# Function to run a single test
run_test() {
    local test_num=$1
    local template_type=$2
    local project_name="perf-test-$test_num-$template_type"
    local test_dir="/tmp/perf-$test_num-$(date +%s)"
    
    echo "Test $test_num: $template_type"
    echo "  Directory: $test_dir"
    
    # Generation timing
    local gen_start=$(date +%s%N)
    cd "$SCRIPT_DIR" && ./generate-project.sh "$project_name" "$template_type" "$test_dir" >/dev/null 2>&1
    local gen_exit=$?
    local gen_end=$(date +%s%N)
    local gen_ms=$(( (gen_end - gen_start) / 1000000 ))
    
    if [ $gen_exit -ne 0 ]; then
        echo "  ❌ Generation failed"
        return 1
    fi
    
    local file_count=$(find "$test_dir" -type f 2>/dev/null | wc -l)
    echo "  ✅ Generated: ${gen_ms}ms, Files: $file_count"
    
    # Validation timing
    local val_start=$(date +%s%N)
    local val_output=$(cd "$SCRIPT_DIR" && ./validate-lightweight.sh "$test_dir" "$template_type" 2>&1)
    local val_exit=$?
    local val_end=$(date +%s%N)
    local val_ms=$(( (val_end - val_start) / 1000000 ))
    
    # Extract quality score
    local quality_score=$(echo "$val_output" | grep -E "Quality score: [0-9.]+" | sed 's/.*Quality score: //' | sed 's/\/10.*//' | head -1)
    if [ -z "$quality_score" ]; then
        quality_score="0"
    fi
    
    if [ $val_exit -eq 0 ]; then
        echo "  ✅ Validated: ${val_ms}ms, Score: $quality_score/10"
    else
        echo "  ⚠️  Validation issues: ${val_ms}ms"
    fi
    
    local total_ms=$((gen_ms + val_ms))
    echo "  📊 Total: ${total_ms}ms"
    
    # Save results
    echo "$test_num,$template_type,$gen_ms,$val_ms,$total_ms,$file_count,$quality_score" >> "$RESULTS_FILE"
    
    # Cleanup
    rm -rf "$test_dir" 2>/dev/null || true
    
    echo ""
    return 0
}

# Run Next.js tests
echo "📊 Running Next.js tests (1-10)..."
echo "----------------------------------"
for i in {1..10}; do
    run_test "$i" "nextjs-fullstack"
done

# Run Express+React tests
echo "📊 Running Express+React tests (11-20)..."
echo "----------------------------------------"
for i in {11..20}; do
    run_test "$i" "express-react"
done

# Analyze results
echo "======================================"
echo "📈 Performance Analysis"
echo ""

# Read results file
if [ ! -f "$RESULTS_FILE" ] || [ $(wc -l < "$RESULTS_FILE") -le 1 ]; then
    echo "❌ No results to analyze"
    exit 1
fi

# Calculate statistics
echo "Overall Statistics:"
echo "------------------"

# Total time stats
TOTAL_TIMES=$(tail -n +2 "$RESULTS_FILE" | cut -d',' -f5)
TOTAL_COUNT=$(echo "$TOTAL_TIMES" | wc -l)

if [ "$TOTAL_COUNT" -gt 0 ]; then
    # Calculate average
    AVG_MS=$(echo "$TOTAL_TIMES" | awk '{sum+=$1} END {print int(sum/NR)}')
    echo "Average total time: ${AVG_MS}ms ($(echo "scale=2; $AVG_MS/1000" | bc)s)"
    
    # Calculate P95 (95th percentile)
    SORTED_TIMES=$(echo "$TOTAL_TIMES" | sort -n)
    P95_INDEX=$(( (TOTAL_COUNT * 95 + 99) / 100 ))  # ceiling
    P95_MS=$(echo "$SORTED_TIMES" | sed -n "${P95_INDEX}p")
    echo "P95 total time: ${P95_MS}ms ($(echo "scale=2; $P95_MS/1000" | bc)s)"
    
    # Check against target
    TARGET_MS=120000  # 2 minutes in milliseconds
    if [ "$P95_MS" -lt "$TARGET_MS" ]; then
        echo "✅ P95 < 2 minutes target: MET"
    else
        echo "❌ P95 < 2 minutes target: NOT MET"
        echo "   Difference: $(echo "scale=2; ($P95_MS - $TARGET_MS)/1000" | bc)s over target"
    fi
    
    # Generation vs validation breakdown
    GEN_AVG=$(tail -n +2 "$RESULTS_FILE" | cut -d',' -f3 | awk '{sum+=$1} END {print int(sum/NR)}')
    VAL_AVG=$(tail -n +2 "$RESULTS_FILE" | cut -d',' -f4 | awk '{sum+=$1} END {print int(sum/NR)}')
    echo ""
    echo "Breakdown:"
    echo "  Generation: ${GEN_AVG}ms ($(echo "scale=1; $GEN_AVG*100/$AVG_MS" | bc)%)"
    echo "  Validation: ${VAL_AVG}ms ($(echo "scale=1; $VAL_AVG*100/$AVG_MS" | bc)%)"
    
    # Quality scores
    QUALITY_SCORES=$(tail -n +2 "$RESULTS_FILE" | cut -d',' -f7)
    QUALITY_AVG=$(echo "$QUALITY_SCORES" | awk '{sum+=$1} END {print sum/NR}')
    echo ""
    echo "Quality Scores:"
    echo "  Average: $(echo "scale=1; $QUALITY_AVG" | bc)/10"
    echo "  Target: ≥9.0/10"
    if (( $(echo "$QUALITY_AVG >= 9.0" | bc -l) )); then
        echo "  ✅ Quality target: MET"
    else
        echo "  ❌ Quality target: NOT MET"
    fi
fi

# Template-specific stats
echo ""
echo "Template Comparison:"
echo "-------------------"

# Next.js stats
NEXTJS_TIMES=$(grep "nextjs-fullstack" "$RESULTS_FILE" | cut -d',' -f5)
NEXTJS_COUNT=$(echo "$NEXTJS_TIMES" | wc -l)
if [ "$NEXTJS_COUNT" -gt 0 ]; then
    NEXTJS_AVG=$(echo "$NEXTJS_TIMES" | awk '{sum+=$1} END {print int(sum/NR)}')
    echo "Next.js (n=$NEXTJS_COUNT):"
    echo "  Average: ${NEXTJS_AVG}ms ($(echo "scale=2; $NEXTJS_AVG/1000" | bc)s)"
fi

# Express+React stats
EXPRESS_TIMES=$(grep "express-react" "$RESULTS_FILE" | cut -d',' -f5)
EXPRESS_COUNT=$(echo "$EXPRESS_TIMES" | wc -l)
if [ "$EXPRESS_COUNT" -gt 0 ]; then
    EXPRESS_AVG=$(echo "$EXPRESS_TIMES" | awk '{sum+=$1} END {print int(sum/NR)}')
    echo "Express+React (n=$EXPRESS_COUNT):"
    echo "  Average: ${EXPRESS_AVG}ms ($(echo "scale=2; $EXPRESS_AVG/1000" | bc)s)"
fi

echo ""
echo "======================================"
echo "📋 Results saved to: $RESULTS_FILE"
echo ""
echo "Summary:"
echo "- Tests completed: $TOTAL_COUNT"
echo "- Performance target: P95 < 2 minutes"
echo "- Quality target: ≥9.0/10"
echo ""
echo "Ready for bottleneck analysis and optimization."