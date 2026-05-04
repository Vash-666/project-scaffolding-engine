# Project Scaffolding Engine

A production-ready project scaffolding system that generates clean, type-safe, fully-configured web application projects with zero manual setup required.

[![Quality](https://img.shields.io/badge/Quality-10%2F10-brightgreen)]()
[![Validation](https://img.shields.io/badge/Validation-E2E%20Tested-blue)]()
[![Status](https://img.shields.io/badge/Status-Production%20Ready-success)]()

---

## What This Is

The Project Scaffolding Engine is a carefully crafted system for generating starter projects that actually work. Unlike many templates that require hours of debugging and configuration, these templates generate projects that:

- ✅ Pass TypeScript compilation with zero errors
- ✅ Pass ESLint with zero warnings
- ✅ Build successfully for production
- ✅ Include testing infrastructure
- ✅ Follow modern best practices

## Templates Included

### 1. Next.js Full-Stack Template

A modern React application using Next.js 14+ with the App Router.

**Stack:**
- Next.js 14+ (App Router)
- React 18+
- TypeScript
- Tailwind CSS
- Vitest + React Testing Library
- ESLint + Prettier

**Quality Score:** 10/10 ✅

**Includes:**
- Pre-configured project structure
- Type-safe API routes
- Component architecture
- Testing setup with Vitest
- CI/CD GitHub Actions workflow
- Environment configuration

### 2. Express + React Template

A full-stack application with Express backend and React frontend using npm workspaces.

**Stack:**
- Express.js (backend)
- React 18+ with Vite (frontend)
- TypeScript throughout
- Axios for API communication
- Vitest for testing
- ESLint + Prettier
- npm workspaces for monorepo management

**Quality Score:** 10/10 ✅

**Includes:**
- RESTful API structure
- React frontend with Vite
- Type-safe API client
- Health check endpoints
- Error handling middleware
- Request logging
- CORS configuration

---

## Quick Start

### Using the Scaffold Script

```bash
# Generate a Next.js project
./scripts/generate-project.sh my-app nextjs-fullstack

# Generate an Express+React project
./scripts/generate-project.sh my-app express-react
```

### Manual Template Usage

```bash
# Copy a template
cp -r templates/nextjs-fullstack my-new-project

# Update package.json name
cd my-new-project
# Edit package.json to set your project name

# Install dependencies
npm install

# Run type checking
npm run type-check

# Run linter
npm run lint

# Run tests
npm test

# Build for production
npm run build
```

---

## Validation & Quality

Every template in this repository has been rigorously validated:

### T3.3: Template-Level Quality Gates
- ✅ TypeScript compilation (zero errors)
- ✅ ESLint validation (zero warnings)
- ✅ Build success
- ✅ Structure validation
- ✅ Dependencies check

**Results:** 10/10 for both templates

### T3.4: End-to-End Validation
- ✅ Generated real projects using the scaffold system
- ✅ Full npm install and workspace setup
- ✅ Production builds successful
- ✅ All quality gates passed in real usage

**Results:** 10/10 for both templates

See [`docs/validation/`](docs/validation/) for detailed validation reports.

---

## Project Journey

This project wasn't built in a straight line. It involved real challenges, honest setbacks, and genuine learning.

### The Challenge

Initial validation revealed the templates were fundamentally broken:
- Next.js template: 4.0/10 quality score
- Express+React template: 2.0/10 quality score

Issues included:
- Cross-template pollution from buggy copy commands
- TypeScript configuration errors
- ESLint failures
- Build failures
- Missing type definitions

### The Recovery

Through systematic debugging and targeted fixes:
1. Fixed validation script bugs (cross-template pollution)
2. Resolved TypeScript import path issues
3. Fixed ESLint configuration conflicts
4. Added missing type definitions
5. Validated workspace-aware checks for monorepo template

**Final Result:** Both templates achieved 10/10 quality scores.

### Key Learnings

1. **Validation is non-negotiable** — Templates that "look right" can still be broken
2. **Test in real scenarios** — E2E validation caught issues template-level tests missed
3. **npm workspaces behave differently** — Validation must account for workspace links, not separate node_modules
4. **Minimal targeted fixes beat rewrites** — All fixes were surgical, no large rewrites needed

See [`docs/journey/PROJECT_JOURNEY.md`](docs/journey/PROJECT_JOURNEY.md) for the full story.

---

## Repository Structure

```
project-scaffolding-engine/
├── README.md                  # This file
├── LICENSE                    # MIT License
├── templates/                 # Production-ready templates
│   ├── nextjs-fullstack/     # Next.js 14+ template
│   └── express-react/        # Express + React template
├── scripts/                   # Utility scripts
│   └── generate-project.sh   # Project generation script
├── docs/                      # Documentation
│   ├── journey/              # Project journey & learnings
│   ├── validation/           # Validation reports
│   └── usage/                # Usage guides
├── examples/                  # Generated example projects
│   ├── my-nextjs-app.tar.gz
│   └── my-express-react-app.tar.gz
└── .gitignore
```

---

## Usage Examples

### Next.js Project

```bash
# Generate project
./scripts/generate-project.sh my-web-app nextjs-fullstack

# Start development
cd my-web-app
npm install
npm run dev

# Run quality checks
npm run type-check
npm run lint
npm test

# Build for production
npm run build
```

### Express + React Project

```bash
# Generate project
./scripts/generate-project.sh my-api-app express-react

# Install dependencies (npm workspaces)
cd my-api-app
npm install

# Start development (concurrently)
npm run dev

# Or start separately
npm run server:dev
npm run client:dev

# Build for production
npm run build
```

---

## Quality Standards

Every template must meet these standards:

| Criteria | Requirement |
|----------|-------------|
| TypeScript | Zero compilation errors |
| ESLint | Zero warnings |
| Build | Successful production build |
| Tests | Test suite passes |
| Structure | All expected directories present |

Templates are validated through:
1. Template-level quality gates (T3.3)
2. End-to-end validation with real projects (T3.4)

---

## Contributing

This project prioritizes quality over quantity. When contributing:

1. Validate your changes using the validation scripts
2. Ensure quality score remains ≥9.0/10
3. Document any changes in validation reports
4. Follow the existing code style and patterns

---

## License

MIT License — See [LICENSE](LICENSE) for details.

---

## Status

**Production Ready** ✅

Both templates have been validated through rigorous testing and are ready for production use. Generated projects require zero manual fixes and work immediately.

---

*Built with careful attention to quality, validated through real-world testing, and documented honestly.*
