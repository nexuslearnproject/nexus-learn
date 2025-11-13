# 📁 Nexus Learn Frontend - Project Structure

## Overview
This document describes the scalable folder structure implemented for the Nexus Learn frontend.

## Directory Structure

```
frontend/
├── app/                          # Next.js 13+ App Router
│   ├── about/                    # About page
│   │   └── page.tsx
│   ├── courses/                  # Courses section
│   │   ├── [id]/                 # Dynamic course detail
│   │   │   └── page.tsx
│   │   └── page.tsx              # All courses listing
│   ├── dashboard/                # Dashboard page
│   │   └── page.tsx
│   ├── layout.tsx                # Root layout
│   └── page.tsx                  # Landing page
│
├── components/                   # React components (organized by type)
│   ├── features/                 # Feature-specific components
│   │   ├── auth/
│   │   │   ├── AuthModal.tsx
│   │   │   └── index.ts         # Barrel export
│   │   ├── courses/
│   │   │   ├── CourseCard.tsx
│   │   │   ├── CategoryCard.tsx
│   │   │   └── index.ts         # Barrel export
│   │   └── testimonials/
│   │       ├── TestimonialCard.tsx
│   │       └── index.ts         # Barrel export
│   │
│   ├── layout/                   # Layout components
│   │   ├── Navbar.tsx
│   │   ├── Hero.tsx
│   │   ├── NexusLearnLogo.tsx
│   │   └── index.ts             # Barrel export
│   │
│   └── ui/                       # Reusable UI components (shadcn/ui)
│       ├── button.tsx
│       ├── card.tsx
│       ├── badge.tsx
│       ├── dialog.tsx
│       ├── dropdown-menu.tsx
│       ├── sheet.tsx
│       ├── avatar.tsx
│       ├── input.tsx
│       ├── checkbox.tsx
│       ├── label.tsx
│       ├── utils.ts
│       └── index.ts             # Barrel export
│
├── contexts/                     # React contexts
│   ├── LanguageContext.tsx
│   └── NavigationContext.tsx
│
├── hooks/                        # Custom React hooks (ready for future use)
│   └── (add custom hooks here)
│
├── lib/                          # Utility functions
│   └── utils.ts
│
├── services/                     # API services (ready for future use)
│   └── (add API services here)
│
├── styles/                       # Global styles
│   ├── globals.css
│   └── landing.css
│
├── types/                        # TypeScript type definitions
│   ├── course.ts                # Course-related types
│   └── index.ts                 # Type exports
│
├── config/                       # Configuration files (ready for future use)
│   └── (add config files here)
│
└── public/                       # Static assets
    └── (add images, fonts, etc.)
```

## Path Aliases (tsconfig.json)

The project uses TypeScript path aliases for clean imports:

```typescript
{
  "@/*": ["./*"],
  "@/components/*": ["components/*"],
  "@/lib/*": ["lib/*"],
  "@/hooks/*": ["hooks/*"],
  "@/types/*": ["types/*"],
  "@/services/*": ["services/*"],
  "@/config/*": ["config/*"],
  "@/styles/*": ["styles/*"],
  "@/contexts/*": ["contexts/*"]
}
```

## Import Examples

### ✅ Clean Imports (After Restructuring)

```typescript
// Components
import { Navbar, Hero } from '@/components/layout';
import { CourseCard, CategoryCard } from '@/components/features/courses';
import { TestimonialCard } from '@/components/features/testimonials';
import { AuthModal } from '@/components/features/auth';
import { Button, Card, Badge } from '@/components/ui';

// Contexts
import { LanguageProvider, useLanguage } from '@/contexts/LanguageContext';

// Styles
import '@/styles/globals.css';

// Types
import type { Course, Category } from '@/types';
```

### ❌ Old Imports (Before Restructuring)

```typescript
// Before - messy relative paths
import { Navbar } from '../components/Navbar';
import { Hero } from '../components/Hero';
import { CourseCard } from '../components/CourseCard';
import { Button } from '../components/ui/button';
import '../landing.css';
```

## Benefits

### 1. **Scalability**
- Easy to add new features without cluttering the root
- Clear separation of concerns
- Organized by feature and purpose

### 2. **Maintainability**
- Barrel exports make refactoring easier
- Path aliases eliminate deep relative imports
- Consistent naming conventions

### 3. **Developer Experience**
- Autocomplete works better with path aliases
- Easier to navigate the codebase
- Clear folder structure for new team members

### 4. **Performance**
- Tree-shaking is more effective
- Easier to code-split by feature
- Better bundling optimization

## Folder Naming Conventions

- **Lowercase for folders**: `components/`, `features/`, `auth/`
- **PascalCase for components**: `CourseCard.tsx`, `Navbar.tsx`
- **camelCase for utilities**: `utils.ts`, `constants.ts`
- **index.ts for barrel exports**: Export multiple items from a folder

## Adding New Features

### Example: Adding a "Blog" Feature

1. Create feature folder:
```
components/features/blog/
├── BlogCard.tsx
├── BlogList.tsx
├── BlogDetail.tsx
└── index.ts
```

2. Create barrel export (`index.ts`):
```typescript
export { BlogCard } from './BlogCard';
export { BlogList } from './BlogList';
export { BlogDetail } from './BlogDetail';
```

3. Use clean imports:
```typescript
import { BlogCard, BlogList } from '@/components/features/blog';
```

## Best Practices

1. **Keep components focused** - Single responsibility principle
2. **Use barrel exports** - Group related exports in `index.ts`
3. **Leverage path aliases** - Use `@/` instead of relative paths
4. **Organize by feature** - Group related components together
5. **Type everything** - Define types in `types/` folder
6. **Extract utilities** - Keep reusable logic in `lib/`
7. **Separate concerns** - UI components vs feature components

## Migration Checklist

✅ Created feature-based folders
✅ Moved components to appropriate locations
✅ Created barrel exports (index.ts)
✅ Updated tsconfig.json with path aliases
✅ Updated all imports across the codebase
✅ Moved styles to dedicated folder
✅ Created types folder
✅ Tested application

## Next Steps

To further improve the structure, consider:

1. **Add hooks folder content**
   - `useAuth.ts` - Authentication logic
   - `useCourses.ts` - Course data fetching
   - `useDebounce.ts` - Debounce utility

2. **Add services folder content**
   - `authService.ts` - Authentication API calls
   - `courseService.ts` - Course API calls
   - `userService.ts` - User API calls

3. **Add config folder content**
   - `site.ts` - Site metadata and constants
   - `env.ts` - Environment variable validation

4. **Expand types folder**
   - `user.ts` - User-related types
   - `api.ts` - API response types

5. **Add middleware**
   - `middleware.ts` - For authentication, redirects, etc.

## Resources

- [Next.js App Router](https://nextjs.org/docs/app)
- [TypeScript Path Mapping](https://www.typescriptlang.org/docs/handbook/module-resolution.html#path-mapping)
- [Barrel Exports](https://basarat.gitbook.io/typescript/main-1/barrel)

---

**Last Updated**: November 12, 2024
**Version**: 1.0.0

