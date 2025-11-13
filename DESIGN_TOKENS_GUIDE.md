# 🎨 Design Tokens System - Complete Guide

## 📋 Overview

This project uses a **unified design token system** to maintain consistent design across both **Next.js (web)** and **Flutter (mobile)** platforms.

### What are Design Tokens?

Design tokens are the visual design atoms of the design system — specifically, they are named entities that store visual design attributes. We use them in place of hard-coded values to ensure consistency and easy updates.

## 📁 Project Structure

```
nexus-learn/
├── design-tokens/           # 🎯 Single source of truth
│   ├── tokens.json         # Master design tokens
│   ├── generators/         # Platform-specific generators
│   │   ├── css-generator.js
│   │   ├── dart-generator.js
│   │   └── ts-generator.js
│   └── package.json
│
├── frontend/               # Next.js (Web)
│   ├── styles/
│   │   └── tokens.css     # Generated CSS variables
│   └── config/
│       └── design-tokens.ts  # Generated TypeScript
│
└── mobile/                 # Flutter (Mobile)
    └── lib/
        └── constants/
            └── design_tokens.dart  # Generated Dart
```

## 🚀 Quick Start

### 1. Generate Tokens

```bash
cd design-tokens
node generators/css-generator.js
node generators/dart-generator.js
node generators/ts-generator.js

# Or all at once (requires npm install):
npm run generate
```

### 2. Edit Design Tokens

Edit `design-tokens/tokens.json`:

```json
{
  "colors": {
    "primary": {
      "500": "#3B82F6"  // Change this
    }
  }
}
```

### 3. Regenerate

Run the generators again to update all platforms.

## 🎯 Usage Examples

### Next.js / React

#### Method 1: CSS Variables (Recommended for styling)

```tsx
// In your CSS/Tailwind
.button {
  background-color: var(--color-primary-500);
  padding: var(--spacing-4);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
}
```

#### Method 2: TypeScript Constants

```tsx
import tokens from '@/config/design-tokens';

const MyComponent = () => (
  <div style={{
    color: tokens.colors.primary[500],
    padding: tokens.spacing[4],
    borderRadius: tokens.borderRadius.lg,
    fontFamily: tokens.typography.fontFamily.sans,
  }}>
    Hello World
  </div>
);
```

#### Method 3: Tailwind CSS (Update tailwind.config.js)

```javascript
// tailwind.config.js
const designTokens = require('./config/design-tokens');

module.exports = {
  theme: {
    extend: {
      colors: {
        primary: designTokens.colors.primary,
        secondary: designTokens.colors.secondary,
      },
      spacing: designTokens.spacing,
      borderRadius: designTokens.borderRadius,
    },
  },
};
```

### Flutter / Dart

```dart
import 'constants/design_tokens.dart';

// In your widgets
Container(
  color: AppColors.primary500,
  padding: EdgeInsets.all(AppSpacing.space4),
  child: Text(
    'Hello',
    style: TextStyle(
      fontSize: AppTypography.fontSizeBase,
      fontWeight: AppTypography.fontWeightBold,
      color: AppColors.neutralWhite,
    ),
  ),
  decoration: BoxDecoration(
    borderRadius: AppBorderRadius.lg,
    boxShadow: [
      BoxShadow(
        blurRadius: AppShadows.elevation2,
        color: Colors.black26,
      ),
    ],
  ),
)
```

## 📚 Available Tokens

### Colors

| Token | CSS Variable | TypeScript | Dart |
|-------|-------------|------------|------|
| Primary Blue 500 | `var(--color-primary-500)` | `colors.primary[500]` | `AppColors.primary500` |
| Secondary Purple 500 | `var(--color-secondary-500)` | `colors.secondary[500]` | `AppColors.secondary500` |
| Success Green | `var(--color-semantic-success)` | `colors.semantic.success` | `AppColors.semanticSuccess` |
| Error Red | `var(--color-semantic-error)` | `colors.semantic.error` | `AppColors.semanticError` |

### Typography

| Token | CSS Variable | TypeScript | Dart |
|-------|-------------|------------|------|
| Font Size Base | `var(--font-size-base)` | `typography.fontSize.base` | `AppTypography.fontSizeBase` |
| Font Weight Bold | `var(--font-weight-bold)` | `typography.fontWeight.bold` | `AppTypography.fontWeightBold` |
| Line Height Normal | `var(--line-height-normal)` | `typography.lineHeight.normal` | `AppTypography.lineHeightNormal` |

### Spacing

| Token | Value | CSS | TypeScript | Dart |
|-------|-------|-----|------------|------|
| Space 0 | 0 | `var(--spacing-0)` | `spacing[0]` | `AppSpacing.space0` |
| Space 4 | 1rem (16px) | `var(--spacing-4)` | `spacing[4]` | `AppSpacing.space4` |
| Space 8 | 2rem (32px) | `var(--spacing-8)` | `spacing[8]` | `AppSpacing.space8` |

### Border Radius

| Token | Value | CSS | TypeScript | Dart |
|-------|-------|-----|------------|------|
| Small | 0.125rem | `var(--radius-sm)` | `borderRadius.sm` | `AppBorderRadius.sm` |
| Medium | 0.375rem | `var(--radius-md)` | `borderRadius.md` | `AppBorderRadius.md` |
| Large | 0.5rem | `var(--radius-lg)` | `borderRadius.lg` | `AppBorderRadius.lg` |
| Full | 9999px | `var(--radius-full)` | `borderRadius.full` | `AppBorderRadius.full` |

## 🔄 Workflow

### Adding New Tokens

1. **Edit** `design-tokens/tokens.json`:
   ```json
   {
     "colors": {
       "brand": {
         "500": "#FF6B6B"  // New brand color
       }
     }
   }
   ```

2. **Generate**:
   ```bash
   cd design-tokens
   node generators/css-generator.js
   node generators/dart-generator.js
   node generators/ts-generator.js
   ```

3. **Use** in your code:
   - **CSS**: `var(--color-brand-500)`
   - **TypeScript**: `colors.brand[500]`
   - **Dart**: `AppColors.brand500`

4. **Commit** all generated files to Git

### Updating Existing Tokens

Simply change the value in `tokens.json` and regenerate!

```json
{
  "spacing": {
    "4": "1.5rem"  // Changed from 1rem to 1.5rem
  }
}
```

All platforms will automatically use the new value.

## ✨ Best Practices

### DO ✅
- ✅ Always edit `tokens.json` as the single source of truth
- ✅ Regenerate tokens after every change
- ✅ Commit generated files to version control
- ✅ Use semantic names (primary, secondary, success, error)
- ✅ Use CSS variables for dynamic theming
- ✅ Document custom tokens in comments

### DON'T ❌
- ❌ Don't edit generated files directly
- ❌ Don't use hard-coded colors/spacing in components
- ❌ Don't skip regenerating after token changes
- ❌ Don't use arbitrary values (use tokens instead)

## 🎨 Color Palette

### Primary (Blue)
- `50-900`: Light to dark blue shades
- Use for: Primary actions, links, focus states

### Secondary (Purple)
- `50-900`: Light to dark purple shades
- Use for: Secondary actions, highlights

### Neutral (Gray)
- `50-900`: Light to dark gray shades
- `white`, `black`: Pure white and black
- Use for: Text, borders, backgrounds

### Semantic
- **Success**: Green (`#10B981`)
- **Warning**: Orange (`#F59E0B`)
- **Error**: Red (`#EF4444`)
- **Info**: Blue (`#3B82F6`)

## 📱 Platform-Specific Notes

### Next.js
- CSS variables are loaded automatically via `globals.css`
- TypeScript tokens provide type safety
- Works seamlessly with Tailwind CSS

### Flutter
- Import `design_tokens.dart` in your files
- Use `AppColors`, `AppTypography`, etc.
- Values are already converted from rem to logical pixels

## 🔧 Troubleshooting

### Tokens not updating in Next.js?
1. Clear `.next` cache: `rm -rf .next`
2. Restart dev server
3. Hard refresh browser (Cmd+Shift+R)

### Tokens not found in Flutter?
1. Check import: `import 'constants/design_tokens.dart';`
2. Run `flutter clean`
3. Restart Flutter app

### Generator errors?
1. Check `tokens.json` is valid JSON
2. Ensure all paths in generators are correct
3. Run with full permissions if needed

## 📊 Token Statistics

- **Colors**: 40+ color variables
- **Typography**: 10+ font sizes, 6 weights
- **Spacing**: 13 spacing units
- **Border Radius**: 9 radius sizes
- **Shadows**: 7 shadow styles
- **Breakpoints**: 5 responsive breakpoints

## 🎓 Resources

- [Design Tokens Specification](https://design-tokens.github.io/community-group/format/)
- [CSS Custom Properties](https://developer.mozilla.org/en-US/docs/Web/CSS/--*)
- [Flutter Theming](https://docs.flutter.dev/cookbook/design/themes)
- [Tailwind CSS Theme](https://tailwindcss.com/docs/theme)

---

**Need help?** Check the `design-tokens/README.md` or ask the team!

**Last Updated**: ${new Date().toLocaleDateString()}

