# Components

This directory contains reusable React components for the PROJECT_NAME application.

## Structure

```
components/
├── ui/                    # Reusable UI components
│   ├── button.tsx        # Button component
│   ├── card.tsx          # Card component
│   └── badge.tsx         # Badge component
└── README.md             # This file
```

## UI Components

### Button
A versatile button component with multiple variants and sizes.

**Usage:**
```tsx
import { Button } from '@/components/ui/button'

<Button variant="default" size="lg">Click me</Button>
<Button variant="outline" size="sm">Outline</Button>
<Button variant="destructive">Delete</Button>
```

**Variants:**
- `default` - Primary button
- `destructive` - For destructive actions
- `outline` - Outlined button
- `secondary` - Secondary button
- `ghost` - Ghost button
- `link` - Link-style button

**Sizes:**
- `default` - Medium size
- `sm` - Small size
- `lg` - Large size
- `icon` - Icon button

### Card
A flexible card component for content containers.

**Usage:**
```tsx
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'

<Card>
  <CardHeader>
    <CardTitle>Card Title</CardTitle>
    <CardDescription>Card description</CardDescription>
  </CardHeader>
  <CardContent>
    Card content goes here
  </CardContent>
</Card>
```

### Badge
A small badge component for labels and status indicators.

**Usage:**
```tsx
import { Badge } from '@/components/ui/badge'

<Badge variant="default">Default</Badge>
<Badge variant="secondary">Secondary</Badge>
<Badge variant="destructive">Destructive</Badge>
<Badge variant="outline">Outline</Badge>
```

## Creating New Components

When creating new components:

1. **Place in appropriate directory:**
   - UI components → `components/ui/`
   - Page-specific components → `components/[page-name]/`
   - Layout components → `components/layout/`

2. **Follow naming conventions:**
   - Use PascalCase for component files
   - Use descriptive names
   - Include TypeScript types

3. **Add documentation:**
   - Include JSDoc comments
   - Document props and usage
   - Add examples if complex

4. **Test components:**
   - Write unit tests in `__tests__/` directory
   - Test different variants and states
   - Test accessibility

## Best Practices

1. **Reusability:** Design components to be reusable across the application
2. **Composition:** Build complex components from simple ones
3. **Type Safety:** Use TypeScript for all components
4. **Accessibility:** Follow WCAG guidelines
5. **Performance:** Use React.memo for expensive components
6. **Styling:** Use Tailwind CSS with consistent design tokens

## Adding to This Documentation

When adding new components, update this README with:
- Component name and purpose
- Usage examples
- Available props and variants
- Any special considerations

---

**Last Updated:** CURRENT_DATE