# Scaffold Skill

**Skill ID:** scaffold  
**Agent:** @scaffolder  
**Purpose:** Generate production-ready web application projects from templates

---

## Overview

The Scaffold skill provides end-to-end project generation with quality validation and optional GitHub integration. It transforms a simple command into a complete, working codebase.

---

## Commands

### `create`

Generate a new project from a template.

**Syntax:**
```
create <project-name> <template> [options]
```

**Parameters:**
- `project-name` - Name for the project (alphanumeric, hyphens, underscores)
- `template` - Template to use (`nextjs-fullstack`, `express-react`)

**Options:**
- `--github` - Push to GitHub after generation
- `--private` - Create private repository (requires `--github`)
- `--description <text>` - Repository description
- `--output-dir <path>` - Output directory (default: current)

**Returns:**
- Success: Project details, quality score, repository URL
- Failure: Error message with diagnosis

**Example:**
```
create my-app nextjs-fullstack --github --description "My web app"
```

---

### `templates`

List available templates.

**Syntax:**
```
templates
```

**Returns:**
- List of templates with descriptions

---

### `check`

Validate setup and prerequisites.

**Syntax:**
```
check
```

**Returns:**
- Status of required tools (git, npm, curl)
- GitHub token status
- Template availability

---

## Templates

### nextjs-fullstack

Modern React application with Next.js 14+.

**Stack:**
- Next.js 14+ (App Router)
- React 18+
- TypeScript
- Tailwind CSS
- Vitest + React Testing Library
- ESLint + Prettier

**Structure:**
```
my-app/
├── src/
│   ├── app/              # Next.js App Router
│   ├── components/       # React components
│   ├── lib/              # Utilities
│   └── types/            # TypeScript types
├── tests/                # Test files
└── package.json
```

**Quality Score:** 10/10 ✅

---

### express-react

Full-stack application with Express backend and React frontend.

**Stack:**
- Express.js (backend)
- React 18+ with Vite (frontend)
- TypeScript throughout
- Axios for API communication
- npm workspaces
- Vitest for testing

**Structure:**
```
my-app/
├── server/               # Express backend
│   ├── src/
│   └── package.json
├── client/               # React frontend
│   ├── src/
│   └── package.json
└── package.json          # Workspace root
```

**Quality Score:** 10/10 ✅

---

## Workflow

### Phase 1: Generation
1. Validate project name
2. Copy template files
3. Update package.json with project name
4. Process template variables

### Phase 2: Installation
1. Run `npm install`
2. Verify dependencies installed

### Phase 3: Quality Gates
1. TypeScript compilation (`tsc --noEmit`)
2. ESLint validation (`eslint --max-warnings 0`)
3. Build verification (`npm run build`)
4. Structure validation (directories present)
5. Dependencies check (node_modules exists)

**Scoring:**
- Each gate: 2 points
- Total: 10 points
- Target: ≥9.0/10

### Phase 4: GitHub Integration (optional)
1. Initialize git repository
2. Create GitHub repository via API
3. Commit all files
4. Push to origin
5. Return repository URL

---

## Quality Gates Detail

### TypeScript Check
- Command: `npx tsc --noEmit`
- Pass: Zero errors
- Fail: Log errors, suggest fixes

### ESLint Check
- Command: `npx eslint src --ext .ts,.tsx --max-warnings 0`
- Pass: Zero errors/warnings
- Fail: Log violations

### Build Check
- Command: `npm run build`
- Pass: Build succeeds
- Fail: Log build errors

### Structure Check
- Verify: src/ or client/src/ and server/src/
- Pass: Expected directories exist
- Fail: Report missing directories

### Dependencies Check
- Verify: node_modules/ exists and has content
- Pass: Dependencies installed
- Fail: Re-run npm install

---

## Error Handling

| Error | Handling |
|-------|----------|
| Invalid project name | Reject with naming rules |
| Template not found | List available templates |
| npm install fails | Retry once, then report |
| Quality < 9.0 | Report issues, continue |
| GitHub API fails | Report error, keep local project |
| Network timeout | Retry with backoff |

---

## Configuration

### Environment Variables

```bash
# Required for GitHub
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"

# Optional
export GITHUB_USERNAME="your-username"
export GITHUB_REPO_VISIBILITY="public"  # or "private"
```

### Skill Configuration

```json
{
  "skill": "scaffold",
  "templates_dir": "./templates",
  "default_output_dir": ".",
  "quality_threshold": 9.0,
  "max_retries": 1
}
```

---

## Scripts

### Main Script

**`scaffold-and-push.sh`**
- Location: `scripts/scaffold-and-push.sh`
- Purpose: End-to-end scaffolding
- Entry point for the skill

### Helper Scripts

**`github-push.sh`**
- Location: `scripts/github-push.sh`
- Purpose: Standalone GitHub push

**`generate-project.sh`**
- Location: `scripts/generate-project.sh`
- Purpose: Basic project generation

---

## Performance

| Phase | Target Time |
|-------|-------------|
| Generation | < 5s |
| Installation | < 60s |
| Quality Gates | < 15s |
| GitHub Push | < 5s |
| **Total** | **< 90s** |

---

## Security

- GitHub token never logged
- Token only from environment
- HTTPS API calls only
- No hardcoded secrets

---

## Usage Flow

```
User: @scaffolder create my-app nextjs-fullstack --github

@scaffolder:
├── Parse: project=my-app, template=nextjs-fullstack, github=true
├── Validate: prerequisites check
├── Generate: copy template, update package.json
├── Install: npm install (45s)
├── Quality: TypeScript ✓, ESLint ✓, Build ✓, Structure ✓, Deps ✓
├── Score: 10/10
├── GitHub: init, create repo, push
└── Return: URL, score, path
```

---

## Success Criteria

- [x] Single command generates project
- [x] Quality score ≥ 9.0/10
- [x] GitHub integration optional
- [x] Clear error messages
- [x] < 2 minutes total time

---

**Status:** ✅ Production Ready
