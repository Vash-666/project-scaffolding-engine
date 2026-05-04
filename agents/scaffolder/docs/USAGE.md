# @scaffolder Usage Guide

Complete guide for using the @scaffolder agent to generate production-ready projects.

---

## Quick Start

### Basic Scaffolding

```bash
# Generate a Next.js project
@scaffolder create my-app nextjs-fullstack

# Generate an Express+React project
@scaffolder create my-api express-react
```

### With GitHub Integration

```bash
# Generate and push to GitHub
@scaffolder create my-app nextjs-fullstack --github

# Private repository
@scaffolder create my-app nextjs-fullstack --github --private
```

---

## Available Commands

### `create` — Generate a New Project

**Syntax:**
```
@scaffolder create <project-name> <template> [options]
```

**Parameters:**
- `project-name` - Name for your project (used for folder and repo)
- `template` - Template to use:
  - `nextjs-fullstack` - Next.js 14+ application
  - `express-react` - Express + React application

**Options:**
- `--github` - Push to GitHub after generation
- `--private` - Create private repository (with `--github`)
- `--description "text"` - Repository description
- `--output-dir /path` - Custom output directory

**Examples:**

```bash
# Basic usage
@scaffolder create blog nextjs-fullstack

# With GitHub
@scaffolder create blog nextjs-fullstack --github

# Private repo with description
@scaffolder create blog nextjs-fullstack --github --private --description "My blog"

# Custom output directory
@scaffolder create blog nextjs-fullstack --output-dir ~/projects
```

**What Happens:**
1. Project generated from template
2. Dependencies installed (~40s)
3. Quality gates run (TypeScript, ESLint, Build, Structure, Deps)
4. If `--github`: GitHub repo created and code pushed
5. Results returned with repository URL

**Time:** ~90 seconds

---

### `templates` — List Available Templates

**Syntax:**
```
@scaffolder templates
```

**Output:**
```
Available Templates
===================

nextjs-fullstack
  Next.js 14+ with TypeScript, Tailwind, Vitest
  Quality: 10/10 ✅

express-react
  Express + React with npm workspaces
  Quality: 10/10 ✅
```

---

### `check` — Validate Setup

**Syntax:**
```
@scaffolder check
```

**Purpose:** Verify all prerequisites are installed and configured.

**Checks:**
- ✅ Git installed
- ✅ npm installed
- ✅ curl installed
- ✅ jq installed (optional)
- ✅ GITHUB_TOKEN set (for GitHub integration)
- ✅ Templates available

**Example Output:**
```
@scaffolder Setup Check
=======================

  ✅ Git: 2.39.5
  ✅ npm: 11.8.0
  ✅ curl: installed
  ✅ jq: jq-1.6
  ⚠️  GITHUB_TOKEN: not set
  ✅ Template: nextjs-fullstack
  ✅ Template: express-react

Setup check passed!
```

---

## Templates

### nextjs-fullstack

Modern full-stack React application.

**Stack:**
- Next.js 14+ (App Router)
- React 18+
- TypeScript
- Tailwind CSS
- Vitest + React Testing Library
- ESLint + Prettier

**Project Structure:**
```
my-app/
├── src/
│   ├── app/              # Next.js App Router
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── api/          # API routes
│   ├── components/       # React components
│   ├── lib/              # Utilities
│   └── types/            # TypeScript types
├── tests/                # Test files
├── public/               # Static assets
└── package.json
```

**Quality Score:** 10/10 ✅

**Commands:**
```bash
cd my-app
npm run dev        # Start dev server
npm run build      # Production build
npm test           # Run tests
npm run lint       # Run ESLint
```

---

### express-react

Full-stack application with separate backend and frontend.

**Stack:**
- Express.js (backend)
- React 18+ with Vite (frontend)
- TypeScript throughout
- Axios for API communication
- npm workspaces
- Vitest for testing

**Project Structure:**
```
my-app/
├── server/               # Backend
│   ├── src/
│   │   ├── index.ts
│   │   ├── routes/
│   │   └── middleware/
│   └── package.json
├── client/               # Frontend
│   ├── src/
│   │   ├── App.tsx
│   │   ├── components/
│   │   └── services/
│   └── package.json
└── package.json          # Workspace root
```

**Quality Score:** 10/10 ✅

**Commands:**
```bash
cd my-app
npm run dev        # Start both (concurrently)
npm run server:dev # Start server only
npm run client:dev # Start client only
npm run build      # Build both
```

---

## GitHub Integration Setup

### Step 1: Generate GitHub Token

1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scopes:
   - ✅ `repo` - Full control of private repositories
   - ✅ `workflow` - Update GitHub Action workflows
4. Click "Generate token"
5. Copy the token (starts with `ghp_`)

### Step 2: Configure Environment

**Option A: Export (current session only)**
```bash
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
```

**Option B: Add to shell profile (persistent)**
```bash
echo 'export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"' >> ~/.zshrc
source ~/.zshrc
```

**Option C: Use with command**
```bash
GITHUB_TOKEN="ghp_xxxxxxxxxxxx" @scaffolder create my-app nextjs-fullstack --github
```

### Step 3: Verify Setup

```bash
@scaffolder check
```

Should show: `✅ GITHUB_TOKEN: set`

---

## Quality Gates

Every generated project is validated against these gates:

| Gate | Description | Points |
|------|-------------|--------|
| TypeScript | Zero compilation errors | 2/10 |
| ESLint | Zero warnings | 2/10 |
| Build | Production build succeeds | 2/10 |
| Structure | All directories present | 2/10 |
| Dependencies | All installed correctly | 2/10 |
| **Total** | | **10/10** |

**Target:** ≥ 9.0/10

If a project fails quality gates, @scaffolder will report issues but still return the project (you can fix manually).

---

## Example Sessions

### Example 1: Blog Application

```
User: @scaffolder create my-blog nextjs-fullstack --github --description "Personal blog"

@scaffolder:
========================================
  OpenClaw Scaffolding Engine
========================================

[INFO] Project: my-blog
[INFO] Template: nextjs-fullstack
[INFO] GitHub Push: true

Phase 1: Project Generation
[SUCCESS] Project generated

Phase 2: Dependency Installation
[SUCCESS] Dependencies installed (42s)

Phase 3: Quality Validation
[SUCCESS] TypeScript: PASS
[SUCCESS] ESLint: PASS
[SUCCESS] Build: PASS
[SUCCESS] Structure: PASS
[SUCCESS] Dependencies: PASS

Quality Score: 10/10

Phase 4: GitHub Integration
[SUCCESS] Repository created
[SUCCESS] Code pushed to GitHub

========================================
  Scaffolding Complete!
========================================

[SUCCESS] Project: my-blog
[SUCCESS] Repository: https://github.com/username/my-blog
[SUCCESS] Location: ./my-blog

Next steps:
  cd my-blog
  npm run dev
```

### Example 2: Private API

```
User: @scaffolder create internal-api express-react --github --private

@scaffolder:
✅ Private project created!

Project: internal-api
Template: express-react
Quality Score: 10/10
Repository: https://github.com/username/internal-api (private)
Location: ./internal-api

Next steps:
  cd internal-api
  npm run dev
```

### Example 3: Local Development

```
User: @scaffolder create experiment nextjs-fullstack

@scaffolder:
✅ Project scaffolding complete!

Project: experiment
Template: nextjs-fullstack
Quality Score: 10/10
Location: ./experiment

Next steps:
  cd experiment
  npm run dev
```

---

## Troubleshooting

### "GITHUB_TOKEN not set"

**Cause:** Missing GitHub token  
**Fix:** Follow [GitHub Integration Setup](#github-integration-setup)

### "Template not found"

**Cause:** Typo in template name  
**Fix:** Use `nextjs-fullstack` or `express-react` (check with `@scaffolder templates`)

### "npm install failed"

**Cause:** Network issues or npm problems  
**Fix:**
```bash
npm cache clean --force
# Retry the command
```

### "Quality check failed"

**Cause:** Project has TypeScript/ESLint errors  
**Fix:** Check logs, fix issues, or use as-is and fix manually

### "GitHub push failed"

**Cause:** Authentication or network issues  
**Fix:**
1. Verify token: `@scaffolder check`
2. Check network connection
3. Push manually if needed

---

## Best Practices

1. **Run `@scaffolder check` first** - Verify setup before creating projects
2. **Use descriptive names** - `customer-portal` not `app1`
3. **Add descriptions** - Makes repositories more discoverable
4. **Start local first** - Test without `--github` to verify template
5. **Check quality score** - Aim for 10/10, investigate if lower

---

## Tips

### Quick Testing

```bash
# Test without GitHub (faster)
@scaffolder create test-app nextjs-fullstack

# Clean up when done
rm -rf test-app
```

### Multiple Projects

```bash
# Create several projects
@scaffolder create frontend nextjs-fullstack --github
@scaffolder create backend express-react --github --private
@scaffolder create mobile nextjs-fullstack
```

### Custom Locations

```bash
# Organize by type
@scaffolder create blog nextjs-fullstack --output-dir ~/projects/web
@scaffolder create api express-react --output-dir ~/projects/apis
```

---

## Advanced Usage

### Working with Generated Projects

After scaffolding:

```bash
cd my-app

# Development
npm run dev

# Testing
npm test

# Building
npm run build

# Quality
npm run type-check
npm run lint
```

### Updating Dependencies

```bash
cd my-app
npm update
npm outdated
```

### Adding Features

Generated projects are standard npm projects—add any packages:

```bash
cd my-app
npm install some-package
```

---

## Getting Help

### In-Agent Help

```
@scaffolder help
```

### Check Setup

```
@scaffolder check
```

### Documentation

- This guide
- [GitHub Integration Guide](../agent/skills/scaffold/docs/GITHUB_INTEGRATION.md)
- [Project Templates](../templates/)

---

## Feedback

Found an issue or have a suggestion? The @scaffolder agent maintains memory of recent tasks—feedback helps improve future scaffolding.

---

**Happy scaffolding! 🚀**
