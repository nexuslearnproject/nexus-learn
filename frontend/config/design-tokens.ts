// Auto-generated from design tokens - DO NOT EDIT MANUALLY
// Last generated: 2025-11-12T02:42:23.898Z

export const designTokens = {
  "colors": {
    "primary": {
      "50": "#EFF6FF",
      "100": "#DBEAFE",
      "200": "#BFDBFE",
      "300": "#93C5FD",
      "400": "#60A5FA",
      "500": "#3B82F6",
      "600": "#2563EB",
      "700": "#1D4ED8",
      "800": "#1E40AF",
      "900": "#1E3A8A"
    },
    "secondary": {
      "50": "#F5F3FF",
      "100": "#EDE9FE",
      "200": "#DDD6FE",
      "300": "#C4B5FD",
      "400": "#A78BFA",
      "500": "#8B5CF6",
      "600": "#7C3AED",
      "700": "#6D28D9",
      "800": "#5B21B6",
      "900": "#4C1D95"
    },
    "neutral": {
      "50": "#F9FAFB",
      "100": "#F3F4F6",
      "200": "#E5E7EB",
      "300": "#D1D5DB",
      "400": "#9CA3AF",
      "500": "#6B7280",
      "600": "#4B5563",
      "700": "#374151",
      "800": "#1F2937",
      "900": "#111827",
      "white": "#FFFFFF",
      "black": "#000000"
    },
    "semantic": {
      "success": "#10B981",
      "warning": "#F59E0B",
      "error": "#EF4444",
      "info": "#3B82F6"
    }
  },
  "typography": {
    "fontFamily": {
      "sans": "Inter, system-ui, -apple-system, sans-serif",
      "mono": "JetBrains Mono, Menlo, Monaco, monospace"
    },
    "fontSize": {
      "xs": "0.75rem",
      "sm": "0.875rem",
      "base": "1rem",
      "lg": "1.125rem",
      "xl": "1.25rem",
      "2xl": "1.5rem",
      "3xl": "1.875rem",
      "4xl": "2.25rem",
      "5xl": "3rem",
      "6xl": "3.75rem"
    },
    "fontWeight": {
      "light": "300",
      "normal": "400",
      "medium": "500",
      "semibold": "600",
      "bold": "700",
      "extrabold": "800"
    },
    "lineHeight": {
      "tight": "1.25",
      "normal": "1.5",
      "relaxed": "1.75",
      "loose": "2"
    }
  },
  "spacing": {
    "0": "0",
    "1": "0.25rem",
    "2": "0.5rem",
    "3": "0.75rem",
    "4": "1rem",
    "5": "1.25rem",
    "6": "1.5rem",
    "8": "2rem",
    "10": "2.5rem",
    "12": "3rem",
    "16": "4rem",
    "20": "5rem",
    "24": "6rem",
    "32": "8rem"
  },
  "borderRadius": {
    "none": "0",
    "sm": "0.125rem",
    "base": "0.25rem",
    "md": "0.375rem",
    "lg": "0.5rem",
    "xl": "0.75rem",
    "2xl": "1rem",
    "3xl": "1.5rem",
    "full": "9999px"
  },
  "shadows": {
    "sm": "0 1px 2px 0 rgba(0, 0, 0, 0.05)",
    "base": "0 1px 3px 0 rgba(0, 0, 0, 0.1)",
    "md": "0 4px 6px -1px rgba(0, 0, 0, 0.1)",
    "lg": "0 10px 15px -3px rgba(0, 0, 0, 0.1)",
    "xl": "0 20px 25px -5px rgba(0, 0, 0, 0.1)",
    "2xl": "0 25px 50px -12px rgba(0, 0, 0, 0.25)",
    "inner": "inset 0 2px 4px 0 rgba(0, 0, 0, 0.06)"
  },
  "breakpoints": {
    "sm": "640px",
    "md": "768px",
    "lg": "1024px",
    "xl": "1280px",
    "2xl": "1536px"
  }
} as const;

export type DesignTokens = typeof designTokens;

// Type-safe color accessors
export const colors = {
  primary: {
    50: '#EFF6FF' as const,
    100: '#DBEAFE' as const,
    200: '#BFDBFE' as const,
    300: '#93C5FD' as const,
    400: '#60A5FA' as const,
    500: '#3B82F6' as const,
    600: '#2563EB' as const,
    700: '#1D4ED8' as const,
    800: '#1E40AF' as const,
    900: '#1E3A8A' as const,
  },
  secondary: {
    50: '#F5F3FF' as const,
    100: '#EDE9FE' as const,
    200: '#DDD6FE' as const,
    300: '#C4B5FD' as const,
    400: '#A78BFA' as const,
    500: '#8B5CF6' as const,
    600: '#7C3AED' as const,
    700: '#6D28D9' as const,
    800: '#5B21B6' as const,
    900: '#4C1D95' as const,
  },
  neutral: {
    50: '#F9FAFB' as const,
    100: '#F3F4F6' as const,
    200: '#E5E7EB' as const,
    300: '#D1D5DB' as const,
    400: '#9CA3AF' as const,
    500: '#6B7280' as const,
    600: '#4B5563' as const,
    700: '#374151' as const,
    800: '#1F2937' as const,
    900: '#111827' as const,
    white: '#FFFFFF' as const,
    black: '#000000' as const,
  },
  semantic: {
    success: '#10B981' as const,
    warning: '#F59E0B' as const,
    error: '#EF4444' as const,
    info: '#3B82F6' as const,
  },
} as const;

// Spacing utilities
export const spacing = {
  0: '0' as const,
  1: '0.25rem' as const,
  2: '0.5rem' as const,
  3: '0.75rem' as const,
  4: '1rem' as const,
  5: '1.25rem' as const,
  6: '1.5rem' as const,
  8: '2rem' as const,
  10: '2.5rem' as const,
  12: '3rem' as const,
  16: '4rem' as const,
  20: '5rem' as const,
  24: '6rem' as const,
  32: '8rem' as const,
} as const;

// Typography utilities
export const typography = {
  fontFamily: {
    sans: 'Inter, system-ui, -apple-system, sans-serif' as const,
    mono: 'JetBrains Mono, Menlo, Monaco, monospace' as const,
  },
  fontSize: {
    xs: '0.75rem' as const,
    sm: '0.875rem' as const,
    base: '1rem' as const,
    lg: '1.125rem' as const,
    xl: '1.25rem' as const,
    2xl: '1.5rem' as const,
    3xl: '1.875rem' as const,
    4xl: '2.25rem' as const,
    5xl: '3rem' as const,
    6xl: '3.75rem' as const,
  },
  fontWeight: {
    light: 300 as const,
    normal: 400 as const,
    medium: 500 as const,
    semibold: 600 as const,
    bold: 700 as const,
    extrabold: 800 as const,
  },
  lineHeight: {
    tight: 1.25 as const,
    normal: 1.5 as const,
    relaxed: 1.75 as const,
    loose: 2 as const,
  },
} as const;

// Border radius utilities
export const borderRadius = {
  none: '0' as const,
  sm: '0.125rem' as const,
  base: '0.25rem' as const,
  md: '0.375rem' as const,
  lg: '0.5rem' as const,
  xl: '0.75rem' as const,
  2xl: '1rem' as const,
  3xl: '1.5rem' as const,
  full: '9999px' as const,
} as const;

// Shadow utilities
export const shadows = {
  sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)' as const,
  base: '0 1px 3px 0 rgba(0, 0, 0, 0.1)' as const,
  md: '0 4px 6px -1px rgba(0, 0, 0, 0.1)' as const,
  lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1)' as const,
  xl: '0 20px 25px -5px rgba(0, 0, 0, 0.1)' as const,
  2xl: '0 25px 50px -12px rgba(0, 0, 0, 0.25)' as const,
  inner: 'inset 0 2px 4px 0 rgba(0, 0, 0, 0.06)' as const,
} as const;

// Breakpoint utilities
export const breakpoints = {
  sm: '640px' as const,
  md: '768px' as const,
  lg: '1024px' as const,
  xl: '1280px' as const,
  2xl: '1536px' as const,
} as const;

// Default export
export default {
  colors,
  spacing,
  typography,
  borderRadius,
  shadows,
  breakpoints,
};
