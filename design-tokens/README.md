# 🎨 Design Tokens

Shared design tokens for **Nexus Learn** - ensuring consistent design across Next.js (web) and Flutter (mobile) platforms.

## 📁 Structure

```
design-tokens/
├── tokens.json          # Source of truth for all design tokens
├── generators/          # Platform-specific generators
│   ├── css-generator.js        # Generates CSS variables
│   ├── dart-generator.js       # Generates Flutter constants
│   └── ts-generator.js         # Generates TypeScript types
├── package.json         # Build scripts
└── README.md           # This file
```

## 🚀 Usage

### Generate Tokens

```bash
cd design-tokens
npm install
npm run generate
```

This will generate:
- `frontend/styles/tokens.css` - CSS variables for Next.js
- `frontend/config/design-tokens.ts` - TypeScript types for Next.js
- `mobile/lib/constants/design_tokens.dart` - Dart constants for Flutter

### Watch Mode

Auto-regenerate when `tokens.json` changes:

```bash
npm run watch
```

### Validate Tokens

Check if `tokens.json` is valid:

```bash
npm run validate
```

## 📝 Token Structure

### Colors
```json
{
  "colors": {
    "primary": { "50": "#EFF6FF", ..., "900": "#1E3A8A" },
    "secondary": { "50": "#F5F3FF", ..., "900": "#4C1D95" },
    "neutral": { "white": "#FFFFFF", ..., "900": "#111827" },
    "semantic": { "success": "#10B981", ... }
  }
}
```

### Typography
```json
{
  "typography": {
    "fontFamily": { "sans": "Inter, ...", "mono": "JetBrains Mono, ..." },
    "fontSize": { "xs": "0.75rem", ..., "6xl": "3.75rem" },
    "fontWeight": { "light": "300", ..., "extrabold": "800" },
    "lineHeight": { "tight": "1.25", ..., "loose": "2" }
  }
}
```

### Spacing
```json
{
  "spacing": {
    "0": "0",
    "1": "0.25rem",
    ...
    "32": "8rem"
  }
}
```

### Border Radius
```json
{
  "borderRadius": {
    "none": "0",
    "sm": "0.125rem",
    ...
    "full": "9999px"
  }
}
```

## 🎯 Platform Usage

### Next.js (CSS Variables)

```tsx
// In CSS
.button {
  background-color: var(--color-primary-500);
  padding: var(--spacing-4);
  border-radius: var(--radius-lg);
}

// Or with TypeScript
import tokens from '@/config/design-tokens';

const styles = {
  color: tokens.colors.primary[500],
  padding: tokens.spacing[4]
};
```

### Flutter (Dart Constants)

```dart
import 'constants/design_tokens.dart';

Container(
  color: AppColors.primary500,
  padding: EdgeInsets.all(AppSpacing.space4),
  decoration: BoxDecoration(
    borderRadius: AppBorderRadius.lg,
  ),
)
```

## 🔄 Workflow

1. **Edit** `tokens.json` with new design values
2. **Generate** tokens: `npm run generate`
3. **Commit** all generated files to Git
4. **Use** tokens in your Next.js and Flutter code

## ✨ Benefits

- ✅ **Single Source of Truth** - One file controls all design
- ✅ **Type Safety** - TypeScript types for Next.js
- ✅ **Consistency** - Same colors/spacing across platforms
- ✅ **Easy Updates** - Change once, update everywhere
- ✅ **Version Control** - Track design changes in Git
- ✅ **Documentation** - Self-documenting design system

## 📚 Resources

- [Design Tokens W3C Community Group](https://www.w3.org/community/design-tokens/)
- [Style Dictionary](https://amzn.github.io/style-dictionary/)
- [Design Systems Handbook](https://www.designbetter.co/design-systems-handbook)

---

**Last Updated**: ${new Date().toLocaleDateString()}
**Version**: 1.0.0

