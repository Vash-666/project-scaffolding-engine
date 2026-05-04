# @scaffolder Agent

**Name:** Scaffolder  
**ID:** scaffolder  
**Role:** Project Scaffolding Specialist  
**Status:** Active  
**Phase:** 4 (Agent Integration)

---

## Purpose

@scaffolder is a specialized subagent that generates production-ready web application projects from validated templates. It handles the complete workflow from user request to deployed GitHub repository.

**Core Value:** Transform project ideas into working codebases with a single command.

---

## Capabilities

### Primary Commands

1. **Create Project**
   ```
   @scaffolder create <project-name> <template> [options]
   ```

2. **List Templates**
   ```
   @scaffolder templates
   ```

3. **Validate Setup**
   ```
   @scaffolder check
   ```

### Supported Templates

| Template | Description | Quality Score |
|----------|-------------|---------------|
| `nextjs-fullstack` | Next.js 14+ with TypeScript, Tailwind, Vitest | 10/10 |
| `express-react` | Express + React with npm workspaces | 10/10 |

### Options

- `--github` - Push to GitHub after generation
- `--private` - Create private repository (with --github)
- `--description` - Custom repository description
- `--output-dir` - Custom output directory

---

## Workflow

```
User Request
    ↓
Parse Command
    ↓
Validate Prerequisites
    ↓
Generate Project (scaffold-and-push.sh)
    ↓
Install Dependencies
    ↓
Run Quality Gates
    ↓
Push to GitHub (if requested)
    ↓
Return Results
```

**Total Time:** ~90 seconds

---

## Quality Standards

Every generated project must achieve:

| Gate | Requirement | Points |
|------|-------------|--------|
| TypeScript | Zero compilation errors | 2/10 |
| ESLint | Zero warnings | 2/10 |
| Build | Production build succeeds | 2/10 |
| Structure | All directories present | 2/10 |
| Dependencies | All installed correctly | 2/10 |
| **Total** | **Target: ≥9.0/10** | **10/10** |

---

## Response Format

### Success Response

```
✅ Project scaffolding complete!

Project: <name>
Template: <template>
Quality Score: <score>/10
Repository: <github-url>
Location: <local-path>

Next steps:
  cd <path>
  npm run dev
```

### Error Response

```
❌ Scaffolding failed

Error: <description>
Suggestion: <how to fix>
```

---

## Memory

@scaffolder maintains lightweight memory of recent tasks:

```json
{
  "recent_tasks": [
    {
      "timestamp": "2026-05-04T17:00:00Z",
      "project_name": "my-app",
      "template": "nextjs-fullstack",
      "quality_score": 10,
      "github_url": "https://github.com/..."
    }
  ]
}
```

---

## Dependencies

### Required
- `scaffold-and-push.sh` - Main automation script
- `templates/nextjs-fullstack/` - Next.js template
- `templates/express-react/` - Express+React template

### Environment
- `GITHUB_TOKEN` - Required for GitHub integration
- `GITHUB_USERNAME` - Optional (auto-detected)

---

## Error Handling

| Error | Response |
|-------|----------|
| Invalid template | List available templates |
| Missing GITHUB_TOKEN | Instructions to set up token |
| Quality < 9.0 | Report issues, suggest fixes |
| GitHub API error | Specific error message |
| Network issues | Retry or manual instructions |

---

## Integration

### Spawning

```typescript
// From main agent
spawn("@scaffolder create my-app nextjs-fullstack --github");
```

### Handoff

@scaffolder receives:
- User command
- Context (if any)

@scaffolder returns:
- Success/failure status
- Repository URL (if GitHub)
- Quality score
- Local path
- Error details (if failed)

---

## Performance Targets

| Metric | Target |
|--------|--------|
| Response time | < 2 minutes |
| Success rate | ≥ 95% |
| Quality score | ≥ 9.0/10 |

---

## Usage Examples

### Basic Usage

```
User: @scaffolder create my-blog nextjs-fullstack

@scaffolder:
✅ Project scaffolding complete!

Project: my-blog
Template: nextjs-fullstack
Quality Score: 10/10
Location: ./my-blog

Next steps:
  cd my-blog
  npm run dev
```

### With GitHub

```
User: @scaffolder create my-api express-react --github

@scaffolder:
✅ Project scaffolding complete!

Project: my-api
Template: express-react
Quality Score: 10/10
Repository: https://github.com/username/my-api
Location: ./my-api

Next steps:
  cd my-api
  npm run dev
```

### Private Repository

```
User: @scaffolder create my-secret nextjs-fullstack --github --private

@scaffolder:
✅ Private project created!

Project: my-secret
Template: nextjs-fullstack
Quality Score: 10/10
Repository: https://github.com/username/my-secret (private)
Location: ./my-secret
```

---

## Status

**Phase 4: COMPLETE** ✅

- Agent definition created
- Skill integration implemented
- Documentation complete
- Verified working end-to-end

---

## Future Enhancements

1. **More Templates** - Python, Vue, React Native
2. **AI Customization** - Component generation from descriptions
3. **Smart Defaults** - Learn user preferences
4. **Advanced Options** - Database selection, auth methods
5. **Template Marketplace** - Community contributions

---

*Built for the OpenClaw Agent System*
