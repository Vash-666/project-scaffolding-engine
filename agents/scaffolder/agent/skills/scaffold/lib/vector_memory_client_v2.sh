#!/bin/bash
#
# Enhanced Vector Memory Client v2 - ARCH-002 Enhancement
# More actionable recommendations and improved context retrieval
#

# Source directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Query vector memory with enhanced retrieval
query_memory_v2() {
    local query="$1"
    local top_k="${2:-5}"
    
    # Use enhanced query interface
    python3 /Users/rohitvashist/.openclaw/agents/shared/vector-memory/agent_query_v2.py "$query" 2>/dev/null
}

# Generate actionable recommendations based on project type and features
generate_actionable_recommendations() {
    local project_type="$1"
    local features="$2"
    local retrieved_context="$3"
    
    echo ""
    echo -e "${MAGENTA}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${MAGENTA}│  🎯 Actionable Implementation Guide                        │${NC}"
    echo -e "${MAGENTA}└────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    # Project type specific actionable guidance
    case "$project_type" in
        blog)
            echo -e "${CYAN}📄 Blog Content System${NC}"
            echo ""
            echo "1. Define Post Schema (src/types/post.ts):"
            echo "   interface BlogPost {"
            echo "     id: string"
            echo "     title: string"
            echo "     slug: string"
            echo "     content: string // Markdown"
            echo "     author: { id: string; name: string }"
            echo "     publishedAt: Date"
            echo "     tags: string[]"
            echo "   }"
            echo ""
            echo "2. Create API Routes:"
            echo "   • GET /api/posts - List all posts"
            echo "   • GET /api/posts/[slug] - Get single post"
            echo "   • POST /api/posts - Create post (protected)"
            echo "   • PUT /api/posts/[slug] - Update post (protected)"
            echo ""
            echo "3. Install Dependencies:"
            echo "   npm install react-markdown remark-gfm gray-matter"
            echo ""
            ;;
            
        dashboard)
            echo -e "${CYAN}📊 Dashboard Data Layer${NC}"
            echo ""
            echo "1. Define Data Types (src/types/dashboard.ts):"
            echo "   interface DashboardWidget {"
            echo "     id: string"
            echo "     type: 'chart' | 'table' | 'metric'"
            echo "     title: string"
            echo "     dataSource: string"
            echo "     config: Record<string, any>"
            echo "   }"
            echo ""
            echo "2. Create Chart Components:"
            echo "   • components/charts/LineChart.tsx"
            echo "   • components/charts/BarChart.tsx"
            echo "   • components/charts/PieChart.tsx"
            echo ""
            echo "3. Install Dependencies:"
            echo "   npm install recharts date-fns"
            echo ""
            ;;
            
        api-service)
            echo -e "${CYAN}⚡ API Architecture${NC}"
            echo ""
            echo "1. Define Resource Types (src/types/resource.ts):"
            echo "   interface Resource {"
            echo "     id: string"
            echo "     createdAt: Date"
            echo "     updatedAt: Date"
            echo "   }"
            echo ""
            echo "2. Create Middleware Stack:"
            echo "   • middleware/auth.ts - JWT verification"
            echo "   • middleware/validation.ts - Request validation"
            echo "   • middleware/error.ts - Error handling"
            echo ""
            echo "3. Implement CRUD Pattern:"
            echo "   • GET /api/resources - List (with pagination)"
            echo "   • GET /api/resources/:id - Get one"
            echo "   • POST /api/resources - Create"
            echo "   • PUT /api/resources/:id - Update"
            echo "   • DELETE /api/resources/:id - Remove"
            echo ""
            ;;
    esac
    
    # Feature-specific actionable guidance
    if echo "$features" | grep -q "user_authentication"; then
        echo -e "${YELLOW}🔐 Authentication Implementation${NC}"
        echo ""
        echo "1. Install Dependencies:"
        echo "   npm install jsonwebtoken bcryptjs"
        echo "   npm install -D @types/jsonwebtoken @types/bcryptjs"
        echo ""
        echo "2. Create Auth Utilities (src/lib/auth.ts):"
        echo "   • hashPassword(password: string): Promise<string>"
        echo "   • verifyPassword(password: string, hash: string): Promise<boolean>"
        echo "   • generateToken(userId: string): string"
        echo "   • verifyToken(token: string): { userId: string }"
        echo ""
        echo "3. Protected Route Middleware:"
        echo "   // middleware.ts or lib/middleware/auth.ts"
        echo "   export function withAuth(handler) {"
        echo "     return async (req, res) => {"
        echo "       const token = req.headers.authorization?.replace('Bearer ', '')"
        echo "       if (!token) return res.status(401).json({ error: 'Unauthorized' })"
        echo "       try {"
        echo "         const { userId } = verifyToken(token)"
        echo "         req.userId = userId"
        echo "         return handler(req, res)"
        echo "       } catch {"
        echo "         return res.status(401).json({ error: 'Invalid token' })"
        echo "       }"
        echo "     }"
        echo "   }"
        echo ""
        echo "4. Auth API Routes:"
        echo "   • POST /api/auth/register - Create account"
        echo "   • POST /api/auth/login - Authenticate"
        echo "   • POST /api/auth/logout - Clear session"
        echo "   • GET /api/auth/me - Get current user (protected)"
        echo ""
    fi
    
    if echo "$features" | grep -q "database_integration"; then
        echo -e "${GREEN}🗄️  Database Layer${NC}"
        echo ""
        echo "1. Install Dependencies:"
        echo "   npm install prisma @prisma/client"
        echo "   npm install -D prisma"
        echo ""
        echo "2. Initialize Prisma:"
        echo "   npx prisma init"
        echo ""
        echo "3. Define Schema (prisma/schema.prisma):"
        echo "   generator client {"
        echo "     provider = 'prisma-client-js'"
        echo "   }"
        echo ""
        echo "   datasource db {"
        echo "     provider = 'postgresql' // or 'sqlite', 'mysql'"
        echo "     url      = env('DATABASE_URL')"
        echo "   }"
        echo ""
        echo "4. Run Migrations:"
        echo "   npx prisma migrate dev --name init"
        echo ""
        echo "5. Generate Client:"
        echo "   npx prisma generate"
        echo ""
    fi
    
    if echo "$features" | grep -q "markdown_support"; then
        echo -e "${CYAN}📝 Markdown Rendering${NC}"
        echo ""
        echo "1. Install Dependencies:"
        echo "   npm install react-markdown remark-gfm rehype-highlight"
        echo ""
        echo "2. Create Markdown Component (src/components/MarkdownRenderer.tsx):"
        echo "   import ReactMarkdown from 'react-markdown'"
        echo "   import remarkGfm from 'remark-gfm'"
        echo ""
        echo "   export function MarkdownRenderer({ content }) {"
        echo "     return ("
        echo "       <ReactMarkdown remarkPlugins={[remarkGfm]}>"
        echo "         {content}"
        echo "       </ReactMarkdown>"
        echo "     )"
        echo "   }"
        echo ""
    fi
    
    echo ""
    echo -e "${MAGENTA}Next Steps:${NC}"
    echo "1. Review the generated project structure"
    echo "2. Install recommended dependencies"
    echo "3. Implement the suggested code patterns"
    echo "4. Run 'npm run dev' to start development"
    echo ""
}

# Get enhanced project context
get_enhanced_project_context() {
    local project_type="$1"
    
    # Query vector memory for relevant patterns
    local query="$project_type project patterns best practices implementation"
    local context
    context=$(query_memory_v2 "$query" 3)
    
    echo "$context"
}

# Export functions for use in agent runner
export -f query_memory_v2
export -f generate_actionable_recommendations
export -f get_enhanced_project_context
