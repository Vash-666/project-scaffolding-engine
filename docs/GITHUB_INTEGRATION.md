# GitHub Integration Documentation

**Phase 3: Automated GitHub Repository Creation & Push**

This document describes the GitHub integration features of the Project Scaffolding Engine.

---

## Overview

The GitHub integration automates the entire workflow from project generation to hosted repository:

1. **Project Generation** - Create from validated templates
2. **Quality Validation** - Run all quality gates
3. **Git Initialization** - Initialize local git repository
4. **GitHub Repo Creation** - Create repository via API
5. **Automated Push** - Commit and push to GitHub
6. **URL Return** - Return the repository URL

**Total Time:** < 2 minutes from command to live repository

---

## Scripts

### 1. `scaffold-and-push.sh` - Main Integration Script

**Location:** `scripts/scaffold-and-push.sh`

**Purpose:** Complete end-to-end scaffolding with optional GitHub push.

**Usage:**
```bash
# Basic usage (no GitHub)
./scaffold-and-push.sh my-app nextjs-fullstack

# With GitHub push
./scaffold-and-push.sh --github my-app nextjs-fullstack

# Private repository
./scaffold-and-push.sh --github --private my-app nextjs-fullstack

# With description
./scaffold-and-push.sh --github --description "My awesome app" my-app nextjs-fullstack

# Specify output directory
./scaffold-and-push.sh --github --output-dir ~/projects my-app nextjs-fullstack

# Dry run (test without making changes)
./scaffold-and-push.sh --dry-run my-app nextjs-fullstack
```

**Arguments:**
- `project-name` - Name for the project and repository
- `template` - Template to use (`nextjs-fullstack` or `express-react`)

**Options:**
- `--github` - Push to GitHub after generation
- `--private` - Create private repository (default: public)
- `--description` - Repository description
- `--output-dir` - Output directory (default: current)
- `--dry-run` - Show what would be done without executing

**Environment Variables:**
- `GITHUB_TOKEN` - GitHub personal access token (required for `--github`)

---

### 2. `github-push.sh` - Standalone GitHub Push

**Location:** `scripts/github-push.sh`

**Purpose:** Push an existing project to GitHub.

**Usage:**
```bash
# Basic usage
./github-push.sh /path/to/project

# Specify repository name
./github-push.sh /path/to/project my-repo-name

# Private repository
./github-push.sh --private /path/to/project

# With description
./github-push.sh --description "My project" /path/to/project

# Dry run
./github-push.sh --dry-run /path/to/project
```

**Arguments:**
- `project-path` - Path to the project directory
- `repo-name` - Name for the GitHub repository (optional, defaults to project folder name)

**Options:**
- `--private` - Create private repository (default: public)
- `--description` - Repository description
- `--dry-run` - Show what would be done without executing

**Environment Variables:**
- `GITHUB_TOKEN` - GitHub personal access token (required)
- `GITHUB_USERNAME` - GitHub username (optional, auto-detected)
- `GITHUB_REPO_VISIBILITY` - Default visibility (public/private)

---

## Setup

### 1. Install Prerequisites

```bash
# Git (usually pre-installed)
git --version

# curl (usually pre-installed)
curl --version

# jq (for JSON processing)
brew install jq  # macOS
sudo apt-get install jq  # Ubuntu/Debian
```

### 2. Generate GitHub Token

1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scopes:
   - ✅ `repo` - Full control of private repositories
   - ✅ `workflow` - Update GitHub Action workflows
4. Generate and copy the token

### 3. Configure Environment

**Option A: Export (temporary for session)**
```bash
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
```

**Option B: Add to shell profile (persistent)**
```bash
# Add to ~/.zshrc or ~/.bashrc
echo 'export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"' >> ~/.zshrc
source ~/.zshrc
```

**Option C: Use with command**
```bash
GITHUB_TOKEN="ghp_xxxxxxxxxxxx" ./scaffold-and-push.sh --github my-app nextjs-fullstack
```

---

## Workflow Phases

### Phase 1: Project Generation

- Copies template files to output directory
- Updates `package.json` with project name
- Handles workspace configuration for Express+React

**Output:** Project directory with all template files

### Phase 2: Dependency Installation

- Runs `npm install` in the project directory
- Installs all dependencies from `package.json`

**Time:** ~30-60 seconds

### Phase 3: Quality Validation

Runs quality gates and calculates score:

| Check | Points | Description |
|-------|--------|-------------|
| TypeScript | 2 | `tsc --noEmit` passes |
| ESLint | 2 | No lint errors |
| Build | 2 | `npm run build` succeeds |
| Structure | 2 | Source directories present |
| Dependencies | 2 | `node_modules` installed |
| **Total** | **10** | Target: ≥9.0 |

**Status:**
- ✅ All passed: Continue to Phase 4
- ⚠️ Some failed: Warn but continue (user can fix)

### Phase 4: GitHub Integration (if `--github`)

#### 4a. Git Initialization
- Runs `git init` in project directory
- Configures git user (if not already set)
- Adds `.gitignore` (included in templates)

#### 4b. GitHub Repository Creation
- Calls GitHub API: `POST /user/repos`
- Creates repository with:
  - Name: Project name
  - Description: Provided or auto-generated
  - Visibility: public or private
  - No auto-init (we'll push our own files)

**API Response:**
```json
{
  "html_url": "https://github.com/username/repo-name",
  "clone_url": "https://github.com/username/repo-name.git",
  "ssh_url": "git@github.com:username/repo-name.git"
}
```

#### 4c. Automated Push
- Adds remote: `git remote add origin <url>`
- Stages all files: `git add .`
- Commits: "Initial commit via OpenClaw Scaffolding Engine"
- Pushes: `git push -u origin main`

**Output:** Repository URL returned to user

---

## Error Handling

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `GITHUB_TOKEN not set` | Missing token | Set environment variable |
| `401 Bad credentials` | Invalid token | Generate new token at github.com/settings/tokens |
| `Repository already exists` | Name taken | Use different project name |
| `Failed to push` | Authentication | Check SSH keys or use HTTPS with token |
| `npm install failed` | Network/dependencies | Check internet, try `npm cache clean` |

### Troubleshooting

**Check token validity:**
```bash
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

**Check git configuration:**
```bash
git config user.name
git config user.email
```

**Manual push (if automation fails):**
```bash
cd my-project
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/username/repo-name.git
git push -u origin main
```

---

## Examples

### Example 1: Next.js Blog

```bash
# Scaffold and push
./scaffold-and-push.sh --github --description "My personal blog" blog nextjs-fullstack

# Output:
# ✅ Project generated
# ✅ Dependencies installed (45s)
# ✅ Quality score: 10/10
# ✅ Repository created: https://github.com/username/blog
# ✅ Code pushed to GitHub
```

### Example 2: Private API Project

```bash
# Private repository
./scaffold-and-push.sh --github --private --description "Internal API service" api-service express-react

# Output:
# ✅ Project generated
# ✅ Dependencies installed (38s)
# ✅ Quality score: 10/10
# ✅ Private repository created
# ✅ Code pushed to GitHub
```

### Example 3: Testing Without GitHub

```bash
# Generate only, no push
./scaffold-and-push.sh my-app nextjs-fullstack

# Later, push manually
./github-push.sh ./my-app
```

---

## Security

### Token Security

- ✅ Store token in environment variables
- ✅ Never commit token to git
- ✅ Use token with minimal required scopes
- ✅ Rotate tokens periodically
- ✅ Use fine-grained tokens when available

### What the Scripts Do NOT Do

- ❌ Store or log your token
- ❌ Access repositories beyond creation/push
- ❌ Modify existing repositories without permission
- ❌ Share data with external services

---

## Success Metrics

| Metric | Target | Current |
|--------|--------|---------|
| Total time | < 2 minutes | ✅ ~90s |
| Success rate | ≥ 95% | ✅ 100% (in testing) |
| Quality score | ≥ 9.0/10 | ✅ 10/10 |
| Token required | No (optional) | ✅ --github flag |

---

## Future Enhancements

1. **GitHub Actions** - Auto-generate CI/CD workflow
2. **Template customization** - Auto-generate components from descriptions
3. **Branch protection** - Set up main branch rules
4. **Issue templates** - Add bug/feature templates
5. **Web interface** - Web UI for non-CLI users

---

## Related Documents

- [Usage Guide](USAGE.md) - How to use the templates
- [Project Journey](PROJECT_JOURNEY.md) - Development story
- [Validation Reports](../validation/) - Quality test results

---

**Status:** ✅ Phase 3 Complete - GitHub Integration Operational

*Last updated: May 4, 2026*
