# P002: Feature Coverage Implementation Plan

**Priority:** 2 (Active)  
**Objective:** Enable generation of actual feature components (not just recommendations)  
**Scope:** Contact Form, Authentication, Data Table  
**Estimated Effort:** 3 hours  
**Status:** Ready for Implementation

---

## Overview

Transform the scaffolding system from "smart template selection" to "intelligent feature generation" by adding a component injection system that generates working pages and components for detected features.

---

## Task Breakdown

### Phase 1: Foundation (30 min)

#### T1.1: Create Feature Component Directory Structure
**File:** `agents/scaffolder/agent/skills/scaffold/templates/feature-components/`
**Action:** Create directory structure for feature component templates
```
feature-components/
├── contact-form/
├── auth-pages/
└── data-table/
```
**Acceptance:** Directory exists and is git-tracked

#### T1.2: Create Component Injector Script
**File:** `agents/scaffolder/agent/skills/scaffold/lib/component-injector.sh`
**Action:** Build script that copies feature components into generated projects
**Key Functions:**
- `inject_feature(feature_name, project_path)` - Copy single feature
- `inject_all_features(features_array, project_path)` - Copy multiple features
- Feature validation (check if template exists before copying)
**Acceptance:** Script can copy feature components to target directory

---

### Phase 2: Contact Form Feature (30 min)

#### T2.1: Create Contact Page
**File:** `feature-components/contact-form/page.tsx`
**Action:** Build /contact page with working form
**Requirements:**
- Use shadcn/ui components (Form, Input, Button, Textarea)
- Client-side validation (required fields, email format)
- Submit button with loading state
- Success/error feedback
- Responsive design
**Acceptance:** Page renders, validation works, form submits

#### T2.2: Create Contact Form Component
**File:** `feature-components/contact-form/ContactForm.tsx`
**Action:** Reusable contact form component
**Requirements:**
- Props for customization (title, description, submitUrl)
- Zod validation schema
- React Hook Form integration
- Styled with Tailwind
**Acceptance:** Component is reusable and functional

#### T2.3: Create Form API Route
**File:** `feature-components/contact-form/api/contact/route.ts`
**Action:** API endpoint for form submission
**Requirements:**
- POST handler
- Request validation
- Mock success response (no real email sending yet)
- Error handling
**Acceptance:** API accepts POST requests, returns success/error

---

### Phase 3: Authentication Feature (45 min)

#### T3.1: Create Login Page
**File:** `feature-components/auth-pages/login/page.tsx`
**Action:** /login page with authentication form
**Requirements:**
- Email/password form
- Client-side validation
- Link to register page
- "Remember me" checkbox
- Error message display
**Acceptance:** Page renders, form validates, navigation works

#### T3.2: Create Register Page
**File:** `feature-components/auth-pages/register/page.tsx`
**Action:** /register page with registration form
**Requirements:**
- Email, password, confirm password fields
- Password strength indicator
- Terms of service checkbox
- Link to login page
**Acceptance:** Page renders, form validates, passwords match check

#### T3.3: Create Auth Context
**File:** `feature-components/auth-pages/AuthContext.tsx`
**Action:** React context for authentication state
**Requirements:**
- User state management
- Login/logout functions
- LocalStorage persistence (client-side only)
- Mock user data
**Acceptance:** Context provides auth state across app

#### T3.4: Create Auth Hook
**File:** `feature-components/auth-pages/useAuth.ts`
**Action:** Custom hook for authentication
**Requirements:**
- useAuth() returns { user, login, logout, isAuthenticated }
- Uses AuthContext internally
- TypeScript types
**Acceptance:** Hook works in components

#### T3.5: Create Protected Route Middleware
**File:** `feature-components/auth-pages/middleware.ts`
**Action:** Next.js middleware for route protection
**Requirements:**
- Check auth status
- Redirect to login if not authenticated
- Allow access to public routes
**Acceptance:** Middleware protects routes correctly

---

### Phase 4: Data Table Feature (30 min)

#### T4.1: Create Data Table Component
**File:** `feature-components/data-table/DataTable.tsx`
**Action:** Reusable data table with sorting/filtering
**Requirements:**
- Use @tanstack/react-table (already in template)
- Sortable columns
- Search/filter input
- Pagination
- Row selection (optional)
- TypeScript generic for data type
**Acceptance:** Component accepts data array, renders table with sorting

#### T4.2: Create Column Definition Helper
**File:** `feature-components/data-table/columns.ts`
**Action:** Helper for creating column definitions
**Requirements:**
- createColumn() helper function
- Common column types (text, number, date, actions)
- Example columns for user data
**Acceptance:** Easy to define columns for any data type

#### T4.3: Create Data Table Page Example
**File:** `feature-components/data-table/page-example.tsx`
**Action:** Example page showing data table usage
**Requirements:**
- Demo with mock data
- Shows sorting, filtering, pagination
- Copy-paste ready for users
**Acceptance:** Example works when copied to project

---

### Phase 5: Parser Enhancement (15 min)

#### T5.1: Update Feature Detection
**File:** `agents/scaffolder/agent/skills/scaffold/lib/project-parser.sh`
**Action:** Add detection for new features
**Additions:**
```bash
# Contact form detection
if echo "$input" | grep -qi "contact"; then
    features=$(echo "$features" | sed 's/\]$/,"contact_form"]/')
fi

# Portfolio detection
if echo "$input" | grep -qi "portfolio"; then
    features=$(echo "$features" | sed 's/\]$/,"portfolio"]/')
fi

# Data table detection
if echo "$input" | grep -qi "data table\|datatable\|table"; then
    features=$(echo "$features" | sed 's/\]$/,"data_table"]/')
fi

# Export detection
if echo "$input" | grep -qi "export\|download"; then
    features=$(echo "$features" | sed 's/\]$/,"export"]/')
fi
```
**Acceptance:** Parser detects new features in test inputs

---

### Phase 6: Integration (10 min)

#### T6.1: Integrate Component Injector
**File:** `agents/scaffolder/scripts/agent-runner-v5.sh`
**Action:** Call component injector after template generation
**Changes:**
- Source the injector script
- After template copy, call: `inject_all_features "$features" "$project_path"`
- Log which features were injected
**Acceptance:** Agent runner calls injector, features appear in output

---

### Phase 7: Testing (20 min)

#### T7.1: Test Contact Form Feature
**Input:** "portfolio site with contact form"
**Verify:**
- [ ] /contact page exists
- [ ] Form validates client-side
- [ ] API route works
- [ ] Success message shows

#### T7.2: Test Authentication Feature
**Input:** "dashboard with authentication"
**Verify:**
- [ ] /login page exists
- [ ] /register page exists
- [ ] Auth context works
- [ ] Can "log in" with mock credentials

#### T7.3: Test Data Table Feature
**Input:** "admin panel with data table"
**Verify:**
- [ ] DataTable component exists
- [ ] Example page works
- [ ] Sorting/filtering functional

#### T7.4: Test Compound Request (Validation Case)
**Input:** "dashboard with authentication, data table, and export functionality"
**Verify:**
- [ ] Dashboard template selected
- [ ] Auth pages injected
- [ ] Data table component injected
- [ ] All 3 features working together

---

## File Inventory

### Files to Create (11)

| # | File | Purpose | Effort |
|---|------|---------|--------|
| 1 | `lib/component-injector.sh` | Injection engine | 20 min |
| 2 | `feature-components/contact-form/page.tsx` | Contact page | 15 min |
| 3 | `feature-components/contact-form/ContactForm.tsx` | Form component | 10 min |
| 4 | `feature-components/contact-form/api/contact/route.ts` | API endpoint | 5 min |
| 5 | `feature-components/auth-pages/login/page.tsx` | Login page | 15 min |
| 6 | `feature-components/auth-pages/register/page.tsx` | Register page | 15 min |
| 7 | `feature-components/auth-pages/AuthContext.tsx` | Auth state | 10 min |
| 8 | `feature-components/auth-pages/useAuth.ts` | Auth hook | 5 min |
| 9 | `feature-components/auth-pages/middleware.ts` | Route protection | 5 min |
| 10 | `feature-components/data-table/DataTable.tsx` | Table component | 20 min |
| 11 | `feature-components/data-table/columns.ts` | Column helper | 5 min |
| 12 | `feature-components/data-table/page-example.tsx` | Example usage | 5 min |

### Files to Modify (2)

| # | File | Change | Effort |
|---|------|--------|--------|
| 1 | `lib/project-parser.sh` | Add feature detection | 15 min |
| 2 | `scripts/agent-runner-v5.sh` | Integrate injector | 10 min |

**Total: 13 files, ~3 hours**

---

## Implementation Order

**Recommended Sequence:**
1. T1.1 + T1.2 → Foundation (injector script)
2. T5.1 → Parser enhancement (so we can test)
3. T2.1 + T2.2 + T2.3 → Contact form (simplest feature)
4. T6.1 → Integration (test contact form end-to-end)
5. T4.1 + T4.2 + T4.3 → Data table (reusable component)
6. T3.1 + T3.2 + T3.3 + T3.4 + T3.5 → Auth (most complex)
7. T7.1 + T7.2 + T7.3 + T7.4 → Testing all features

**Rationale:** Build foundation first, then simplest feature, integrate early, then add complexity.

---

## Success Criteria

### Per-Feature
- [ ] Contact form: Working form with validation and API endpoint
- [ ] Authentication: Working login/register with client-side auth state
- [ ] Data table: Working table with sorting/filtering/pagination

### Integration
- [ ] Parser detects all 3 features from natural language
- [ ] Injector copies components correctly
- [ ] Generated projects include working features
- [ ] No breaking changes to existing functionality

### Validation Test
**Input:** `"dashboard with authentication, data table, and export functionality"`

**Expected Output:**
- Dashboard base template
- /login and /register pages (functional)
- DataTable component (functional)
- Export button in data table
- All features working together
- Quality score ≥9.0/10

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Component conflicts with existing template | Use unique filenames, test integration early |
| Feature detection false positives | Use specific keywords, validate with test cases |
| Injection fails silently | Add logging, verify files exist after injection |
| Dependencies missing | Use only packages already in template |

---

## Blockers

**None identified.**

All required dependencies (shadcn/ui, @tanstack/react-table) are already in the template.

---

## Post-Implementation

### Documentation Updates
- [ ] Update `product/docs/feature-coverage-analysis.md` → mark complete
- [ ] Add feature list to README
- [ ] Update user documentation with examples

### Next Features (Future)
- Image gallery/upload
- Search functionality
- Real-time features (WebSocket)
- Payment integration (Stripe)

---

## Approval Required

**Ready to implement:** Awaiting approval to proceed with Phase 1

**Estimated completion:** Today (3 hours)

**First deliverable:** Foundation + Contact Form (1 hour)
