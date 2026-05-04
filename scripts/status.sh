#!/bin/bash
#
# Quick Status Dashboard for @scaffolder
# Shows system health, metrics, and recent activity
#

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  @scaffolder System Status                                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# System checks
echo "📋 System Health"
echo "────────────────────────────────────────────"

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js: $NODE_VERSION"
else
    echo "❌ Node.js: Not found"
fi

# Check npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo "✅ npm: $NPM_VERSION"
else
    echo "❌ npm: Not found"
fi

# Check Python
if command -v python3 &> /dev/null; then
    echo "✅ Python3: Available"
else
    echo "⚠️  Python3: Not found (Vector Memory disabled)"
fi

echo ""

# Vector Memory Status
echo "🧠 Vector Memory"
echo "────────────────────────────────────────────"

METRICS_FILE="$HOME/.openclaw/.vector_memory/metrics.json"
if [[ -f "$METRICS_FILE" ]]; then
    # Check if metrics exist
    QUERY_COUNT=$(cat "$METRICS_FILE" 2>/dev/null | grep -c '"timestamp"' || echo "0")
    echo "Total Queries: $QUERY_COUNT"
    
    # Try to get latest metrics
    if command -v python3 &> /dev/null; then
        python3 -c "
import json
import sys
try:
    with open('$METRICS_FILE', 'r') as f:
        metrics = json.load(f)
    if metrics:
        recent = metrics[-10:] if len(metrics) > 10 else metrics
        avg_score = sum(m.get('top_score', 0) for m in recent) / len(recent)
        avg_latency = sum(m.get('latency_ms', 0) for m in recent) / len(recent)
        success_rate = sum(1 for m in recent if m.get('success', True)) / len(recent) * 100
        print(f'Recent Avg Score: {avg_score:.3f}')
        print(f'Recent Avg Latency: {avg_latency:.1f}ms')
        print(f'Success Rate: {success_rate:.0f}%')
except Exception as e:
    print(f'Error reading metrics: {e}')
"
    fi
else
    echo "No metrics yet (run a query first)"
fi

echo ""

# Templates
echo "📦 Templates Available"
echo "────────────────────────────────────────────"

TEMPLATE_DIR="agents/scaffolder/agent/skills/scaffold/templates"
if [[ -d "$TEMPLATE_DIR" ]]; then
    ls -1 "$TEMPLATE_DIR" 2>/dev/null | while read template; do
        echo "  • $template"
    done
else
    echo "  Template directory not found"
fi

echo ""

# Recent Projects
echo "📁 Recent Projects (last 5)"
echo "────────────────────────────────────────────"

if command -v find &> /dev/null; then
    find /tmp -maxdepth 1 -name "*blog*" -o -name "*dashboard*" -o -name "*api*" 2>/dev/null | \
        head -5 | while read project; do
        if [[ -d "$project" ]]; then
            NAME=$(basename "$project")
            if [[ -f "$project/.scaffold-result.json" ]]; then
                QUALITY=$(cat "$project/.scaffold-result.json" 2>/dev/null | grep -o '"score": [0-9]*' | awk '{print $2}')
                echo "  • $NAME (Quality: ${QUALITY}/10)"
            else
                echo "  • $NAME"
            fi
        fi
    done
else
    echo "  (check /tmp for recent projects)"
fi

echo ""

# Quick Commands
echo "⚡ Quick Commands"
echo "────────────────────────────────────────────"
echo "  Run project:    ./agents/scaffolder/scripts/agent-runner-v5.sh \"<description>\""