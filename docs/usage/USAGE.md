# Usage Guide

Complete guide for using the Project Scaffolding Engine templates.

---

## Prerequisites

- Node.js 18+ (recommend 20+)
- npm 9+
- Git

---

## Quick Start

### Option 1: Using the Generate Script

The easiest way to create a new project:

```bash
# Clone this repository
git clone https://github.com/vash666/project-scaffolding-engine.git
cd project-scaffolding-engine

# Generate a Next.js project
./scripts/generate-project.sh my-app nextjs-fullstack

# Or generate an Express+React project
./scripts/generate-project.sh my-app express-react
```

### Option 2: Manual Template Copy

```bash
# Copy the template you want
cp -r templates/nextjs-fullstack my-new-project

# Update the project name in package.json
cd my-new-project
# Edit package.json: change "name" field

# Install dependencies
npm install
```

---

## Next.js Full-Stack Template

### What's Included

- **Framework:** Next.js 14+ with App Router
- **Language:** TypeScript
- **Styling:** Tailwind CSS
- **Testing:** Vitest + React Testing Library
- **Linting:** ESLint + Prettier
- **CI/CD:** GitHub Actions workflow

### Project Structure

```
my-app/
├── src/
│   ├── app/              # Next.js App Router
│   │   ├── layout.tsx    # Root layout
│   │   ├── page.tsx      # Home page
│   │   ├── loading.tsx   # Loading state
│   │   └── error.tsx     # Error boundary
│   ├── components/       # React components
│   ├── lib/              # Utilities and helpers
│   ├── types/            # TypeScript types
│   └── hooks/            # Custom React hooks
├── tests/                # Test files
├── public/               # Static assets
├── .github/
│   └── workflows/        # CI/CD workflows
├── package.json
├── tsconfig.json
├── tailwind.config.ts
└── next.config.js
```

### Available Scripts

```bash
# Development
npm run dev              # Start development server

# Building
npm run build            # Build for production
npm run start            # Start production server

# Quality
npm run type-check       # TypeScript type checking
npm run lint             # ESLint
npm run lint:fix         # ESLint with auto-fix
npm run format           # Prettier formatting

# Testing
npm test                 # Run tests
npm run test:watch       # Run tests in watch mode
npm run test:coverage    # Run tests with coverage
```

### Environment Variables

Copy `.env.example` to `.env.local` and customize:

```bash
cp .env.example .env.local
```

Available variables:
- `NEXT_PUBLIC_API_URL` — API endpoint URL
- `NEXT_PUBLIC_APP_NAME` — Application name

---

## Express + React Template

### What's Included

- **Backend:** Express.js with TypeScript
- **Frontend:** React 18+ with Vite
- **Communication:** Axios with type-safe API client
- **Testing:** Vitest for both client and server
- **Linting:** ESLint + Prettier
- **Workspaces:** npm workspaces for monorepo structure

### Project Structure

```
my-app/
├── server/               # Express backend
│   ├── src/
│   │   ├── index.ts      # Server entry point
│   │   ├── routes/       # API routes
│   │   └── middleware/   # Express middleware
│   ├── tests/            # Server tests
│   └── package.json
├── client/               # React frontend
│   ├── src/
│   │   ├── App.tsx       # Main app component
│   │   ├── components/   # React components
│   │   ├── services/     # API services
│   │   ├── types/        # TypeScript types
│   │   └── utils/        # Utilities
│   ├── tests/            # Client tests
│   └── package.json
├── package.json          # Workspace root
└── tsconfig.json
```

### Available Scripts (Root)

```bash
# Development (runs both)
npm run dev              # Start both client and server

# Individual development
npm run server:dev       # Start server only
npm run client:dev       # Start client only

# Building
npm run build            # Build both client and server
npm run server:build     # Build server only
npm run client:build     # Build client only

# Production
npm start                # Start production server

# Quality
npm run type-check       # TypeScript check (both)
npm run lint             # ESLint (both)
npm run lint:fix         # ESLint with auto-fix

# Testing
npm test                 # Run all tests
npm run test:client      # Run client tests
npm run test:server      # Run server tests
```

### Environment Variables

Copy `.env.example` to `.env` and customize:

```bash
cp .env.example .env
```

Server variables:
- `PORT` — Server port (default: 3001)
- `NODE_ENV` — Environment (development/production)
- `CORS_ORIGIN` — Allowed CORS origin

Client variables (in `client/.env.local`):
- `VITE_API_URL` — API endpoint URL

### API Communication

The client includes a type-safe API client:

```typescript
import api from './services/api'

// GET request
const users = await api.get('/users')

// POST request
const newUser = await api.post('/users', { name: 'John' })

// With types
interface User {
  id: number
  name: string
}

const user = await api.get<User>('/users/1')
```

---

## Common Tasks

### Adding a New Route (Next.js)

```bash
# Create the route file
mkdir -p src/app/about
touch src/app/about/page.tsx
```

```tsx
// src/app/about/page.tsx
export default function AboutPage() {
  return <div>About Page</div>
}
```

### Adding a New API Route (Express)

```bash
# Create the route file
touch server/src/routes/users.ts
```

```typescript
// server/src/routes/users.ts
import { Router } from 'express'

const router = Router()

router.get('/', (req, res) => {
  res.json({ users: [] })
})

export default router
```

```typescript
// Register in server/src/routes/index.ts
import usersRouter from './users'

router.use('/users', usersRouter)
```

### Adding Environment Variables

**Next.js:**
```bash
# .env.local
MY_SECRET=value
NEXT_PUBLIC_VISIBLE=value  # Accessible in browser
```

**Express + React:**
```bash
# .env (server)
MY_SECRET=value

# client/.env.local (client)
VITE_MY_VALUE=value  # Must start with VITE_
```

---

## Troubleshooting

### TypeScript Errors

```bash
# Check for errors
npm run type-check

# Clear cache and reinstall
rm -rf node_modules
rm package-lock.json
npm install
```

### ESLint Errors

```bash
# See all errors
npm run lint

# Auto-fix where possible
npm run lint:fix
```

### Build Failures

```bash
# Check TypeScript first
npm run type-check

# Check for missing dependencies
npm install

# Clear Next.js/Vite cache
rm -rf .next dist
npm run build
```

### Port Already in Use

**Next.js:**
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9
```

**Express:**
```bash
# The server will try next available port
# Or set PORT in .env
PORT=3002 npm run server:dev
```

---

## Best Practices

### 1. Run Quality Checks Before Committing

```bash
npm run type-check
npm run lint
npm test
```

### 2. Use Environment Variables for Configuration

Never hardcode URLs, API keys, or secrets. Use `.env` files.

### 3. Keep Components Small and Focused

One component per file, single responsibility.

### 4. Write Tests for Business Logic

```typescript
// tests/utils/calculate.test.ts
import { calculateTotal } from '@/utils/calculate'

test('calculates total with tax', () => {
  expect(calculateTotal(100, 0.1)).toBe(110)
})
```

### 5. Use TypeScript Strictly

Avoid `any` types. Define interfaces for all data structures.

---

## Next Steps

After generating your project:

1. ✅ Update `package.json` name and description
2. ✅ Copy and customize `.env.example`
3. ✅ Run `npm install`
4. ✅ Run quality checks: `npm run type-check && npm run lint`
5. ✅ Start development: `npm run dev`
6. ✅ Write your first component
7. ✅ Add your first test

---

## Getting Help

- Check the [README](../../README.md) for overview
- Review [validation reports](../validation/) for quality details
- Read the [project journey](../journey/PROJECT_JOURNEY.md) for context

---

*Happy building!*
