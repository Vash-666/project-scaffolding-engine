# Feature Coverage Analysis: Compound Request Handling

**Date:** 2026-05-05  
**Status:** Analysis Complete  
**Priority:** 2 (Active)

---

## Problem Statement

**User Request:** "personal portfolio site with blog and contact form"  
**System Response:** Generated blog structure only  
**Missing:** Contact form, portfolio-specific components  
**Gap:** Feature detection works, but feature-to-component generation doesn't

---

## Root Cause Analysis

### 1. Current Flow (Working)

```
User Input → Parser → Feature Detection → Recommendations (text only)
                ↓
         Template Selection (by project type only)
                ↓
         Generic Project Generated
```

### 2. Where It Breaks

| Step | Current | Needed |
|------|---------|--------|
| Feature Detection | ✅ Detects "contact form" | ✅ Already working |
| Feature Storage | ✅ Stores in features array | ✅ Already working |
| Feature-to-Component | ❌ **Nothing** | ✅ Map features to actual components |
| Component Generation | ❌ **Nothing** | ✅ Generate/inject feature components |

### 3. Specific Gaps Found

**Parser (`project-parser.sh`):**
- ✅ Detects: blog, dashboard, api-service types
- ✅ Detects: auth, database features
- ❌ **Missing:** contact_form, portfolio, data_table, image_gallery, etc.

**Template System:**
- ✅ Provides: Generic Next.js starter
- ❌ **Missing:** Feature-specific page/component templates
- ❌ **Missing:** Component injection mechanism

**Intelligence Layer:**
- ✅ Provides: Text recommendations
- ❌ **Missing:** Actual component generation
- ❌ **Missing:** Page structure for detected features

---

## Why This Matters

**User Impact:**
- Request 3 features → Get 1 implemented
- Must manually build missing components
- Feels like "smart template selection" not "intelligent scaffolding"

**System Impact:**
- 10/10 code quality doesn't matter if features are missing
- Recommendations are helpful but require manual work
- Not delivering on "intelligent" promise

---

## Minimal Viable Improvement Plan

### Goal
Enable the system to generate actual components/pages for detected features, not just recommendations.

### Scope (Minimal)
Start with **3 high-impact features**:
1. **Contact Form** → Generate `/contact` page with working form
2. **Authentication** → Generate `/login`, `/register` pages with auth logic
3. **Data Table** → Generate reusable data table component

### Architecture

```
Feature Detection → Component Mapping → Template Injection → Generated Project
       ↓                      ↓                    ↓
  "contact form"      contact-form/         Copy component
  "auth"              auth-pages/           Copy pages + API routes
  "data table"        data-table/           Copy component
```

### Implementation Components

#### 1. Enhanced Parser (1 file, ~30 lines)
Add detection for new features:
```bash
# Add to project-parser.sh
if echo "$input" | grep -qi "contact"; then
    features=$(echo "$features" | sed 's/\]$/,"contact_form"]/')
fi

if echo "$input" | grep -qi "portfolio"; then
    features=$(echo "$features" | sed 's/\]$/,"portfolio"]/')
fi
```

#### 2. Feature Component Templates (3 directories)
Create template components that can be copied:
```
templates/feature-components/
├── contact-form/
│   ├── page.tsx          # /contact page
│   ├── ContactForm.tsx   # Reusable form component
│   └── api/route.ts      # Form submission API
├── auth-pages/
│   ├── login/page.tsx
│   ├── register/page.tsx
│   └── middleware.ts     # Auth protection
└── data-table/
    ├── DataTable.tsx
    └── columns.ts
```

#### 3. Component Injector (1 file, ~50 lines)
New script to copy feature components into generated project:
```bash
# inject-features.sh
for feature in $features; do
    if [[ -d "$FEATURE_TEMPLATES/$feature" ]]; then
        cp -r "$FEATURE_TEMPLATES/$feature"/* "$PROJECT_DIR/src/"
    fi
done
```

#### 4. Integration Point (1 line change)
Call injector in `agent-runner-v5.sh` after template copy:
```bash
# After: cp -r template/* "$project_path/"
# Add:   inject_features "$features" "$project_path"
```

---

## Success Criteria

| Test Case | Input | Expected Output |
|-----------|-------|-----------------|
| TC1 | "portfolio with contact form" | Blog + portfolio structure + working contact page |
| TC2 | "dashboard with auth and data table" | Dashboard + login/register + data table component |
| TC3 | "blog with auth" | Blog + login/register + protected routes |

---

## Validation Test Request

**Recommended Test:**
```
"dashboard with authentication, data table, and export functionality"
```

**Expected Behavior:**
1. Detects: dashboard type + auth + data_table + export features
2. Generates: Base dashboard template
3. Injects: Login/register pages, data table component, export button
4. Result: Functional dashboard with all 3 features working

---

## Effort Estimate

| Component | Effort | Files |
|-----------|--------|-------|
| Enhanced Parser | 15 min | 1 file |
| Contact Form Template | 30 min | 3 files |
| Auth Pages Template | 45 min | 4 files |
| Data Table Template | 30 min | 2 files |
| Component Injector | 20 min | 1 file |
| Integration | 10 min | 1 file |
| Testing | 20 min | - |
| **Total** | **~3 hours** | **12 files** |

---

## Blockers & Questions

**Blockers:** None

**Questions:**
1. Should we use existing UI components (shadcn/ui) or custom?
2. Should auth include database integration or mock storage first?
3. How complex should contact form be (client-side only vs API)?

**Recommendations:**
- Use shadcn/ui components (already in template)
- Start with client-side only (no database required)
- Keep forms simple but functional (validation + submission handling)

---

## Next Steps

1. ✅ Create feature component templates (contact, auth, data-table)
2. ✅ Build component injector script
3. ✅ Enhance parser for new features
4. ✅ Integrate into agent-runner-v5.sh
5. ✅ Test with validation case
6. ✅ Deploy and validate

---

## Related

- Project 1 Feedback: `product/feedback/P001-personal-portfolio-feedback.md`
- @product identified this as #1 improvement needed
- @quality rated template 7/10 due to generic nature

**Status:** Ready for implementation approval
