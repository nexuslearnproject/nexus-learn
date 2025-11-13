# 🚀 Quick Reference - Import Patterns

## Common Import Patterns

### UI Components
```typescript
import { Button, Card, Badge, Input, Dialog } from '@/components/ui';
```

### Layout Components
```typescript
import { Navbar, Hero, NexusLearnLogo } from '@/components/layout';
```

### Feature Components
```typescript
// Courses
import { CourseCard, CategoryCard } from '@/components/features/courses';

// Auth
import { AuthModal } from '@/components/features/auth';

// Testimonials
import { TestimonialCard } from '@/components/features/testimonials';
```

### Contexts
```typescript
import { LanguageProvider, useLanguage } from '@/contexts/LanguageContext';
```

### Styles
```typescript
import '@/styles/globals.css';
import '@/styles/landing.css';
```

### Types
```typescript
import type { Course, Category, Testimonial } from '@/types';
```

## Path Aliases

| Alias | Maps To | Example |
|-------|---------|---------|
| `@/*` | `./` | `@/app/page.tsx` |
| `@/components/*` | `components/*` | `@/components/ui/button` |
| `@/lib/*` | `lib/*` | `@/lib/utils` |
| `@/hooks/*` | `hooks/*` | `@/hooks/useAuth` |
| `@/types/*` | `types/*` | `@/types/course` |
| `@/services/*` | `services/*` | `@/services/api` |
| `@/config/*` | `config/*` | `@/config/site` |
| `@/styles/*` | `styles/*` | `@/styles/globals.css` |
| `@/contexts/*` | `contexts/*` | `@/contexts/LanguageContext` |

## Folder Structure at a Glance

```
frontend/
├── app/              # Pages (Next.js App Router)
├── components/
│   ├── features/     # Feature components
│   ├── layout/       # Layout components
│   └── ui/           # Reusable UI
├── contexts/         # React contexts
├── hooks/            # Custom hooks
├── lib/              # Utilities
├── services/         # API services
├── styles/           # Global styles
├── types/            # TypeScript types
└── config/           # Configuration
```

## Cheat Sheet

### Creating a New Feature

1. **Create folder**: `components/features/[feature-name]/`
2. **Add components**: `FeatureComponent.tsx`
3. **Create barrel**: `index.ts`
4. **Export**: `export { FeatureComponent } from './FeatureComponent';`
5. **Import**: `import { FeatureComponent } from '@/components/features/[feature-name]';`

### Adding a New Page

1. **Create folder**: `app/[page-name]/`
2. **Add page**: `page.tsx`
3. **Import components**: Use `@/` aliases
4. **Wrap providers**: Add `LanguageProvider` if needed

### Adding Types

1. **Create file**: `types/[type-name].ts`
2. **Define interfaces**: `export interface TypeName { ... }`
3. **Export from barrel**: Add to `types/index.ts`
4. **Import**: `import type { TypeName } from '@/types';`

## Tips

💡 **Always use barrel exports** - Makes refactoring easier
💡 **Use path aliases** - No more `../../../`
💡 **Keep components small** - Single responsibility
💡 **Type everything** - Better autocomplete and fewer bugs
💡 **Organize by feature** - Easier to navigate

---

📖 For detailed documentation, see [STRUCTURE.md](./STRUCTURE.md)

