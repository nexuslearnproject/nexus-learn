const fs = require('fs');
const path = require('path');

function generateTypeScript(tokens) {
  let ts = `// Auto-generated from design tokens - DO NOT EDIT MANUALLY\n`;
  ts += `// Last generated: ${new Date().toISOString()}\n\n`;
  
  ts += `export const designTokens = ${JSON.stringify(tokens, null, 2)} as const;\n\n`;
  
  ts += `export type DesignTokens = typeof designTokens;\n\n`;
  
  // Generate type-safe color access
  ts += `// Type-safe color accessors\n`;
  ts += `export const colors = {\n`;
  Object.entries(tokens.colors).forEach(([category, shades]) => {
    ts += `  ${category}: {\n`;
    if (typeof shades === 'object') {
      Object.entries(shades).forEach(([shade, value]) => {
        ts += `    ${shade}: '${value}' as const,\n`;
      });
    }
    ts += `  },\n`;
  });
  ts += `} as const;\n\n`;

  // Generate spacing utilities
  ts += `// Spacing utilities\n`;
  ts += `export const spacing = {\n`;
  Object.entries(tokens.spacing).forEach(([key, value]) => {
    ts += `  ${key}: '${value}' as const,\n`;
  });
  ts += `} as const;\n\n`;

  // Generate typography utilities
  ts += `// Typography utilities\n`;
  ts += `export const typography = {\n`;
  ts += `  fontFamily: {\n`;
  Object.entries(tokens.typography.fontFamily).forEach(([key, value]) => {
    ts += `    ${key}: '${value}' as const,\n`;
  });
  ts += `  },\n`;
  ts += `  fontSize: {\n`;
  Object.entries(tokens.typography.fontSize).forEach(([key, value]) => {
    ts += `    ${key}: '${value}' as const,\n`;
  });
  ts += `  },\n`;
  ts += `  fontWeight: {\n`;
  Object.entries(tokens.typography.fontWeight).forEach(([key, value]) => {
    ts += `    ${key}: ${value} as const,\n`;
  });
  ts += `  },\n`;
  ts += `  lineHeight: {\n`;
  Object.entries(tokens.typography.lineHeight).forEach(([key, value]) => {
    ts += `    ${key}: ${value} as const,\n`;
  });
  ts += `  },\n`;
  ts += `} as const;\n\n`;

  // Generate borderRadius utilities
  ts += `// Border radius utilities\n`;
  ts += `export const borderRadius = {\n`;
  Object.entries(tokens.borderRadius).forEach(([key, value]) => {
    ts += `  ${key}: '${value}' as const,\n`;
  });
  ts += `} as const;\n\n`;

  // Generate shadow utilities
  ts += `// Shadow utilities\n`;
  ts += `export const shadows = {\n`;
  Object.entries(tokens.shadows).forEach(([key, value]) => {
    ts += `  ${key}: '${value}' as const,\n`;
  });
  ts += `} as const;\n\n`;

  // Generate breakpoint utilities
  ts += `// Breakpoint utilities\n`;
  ts += `export const breakpoints = {\n`;
  Object.entries(tokens.breakpoints).forEach(([key, value]) => {
    ts += `  ${key}: '${value}' as const,\n`;
  });
  ts += `} as const;\n\n`;

  // Export all as default
  ts += `// Default export\n`;
  ts += `export default {\n`;
  ts += `  colors,\n`;
  ts += `  spacing,\n`;
  ts += `  typography,\n`;
  ts += `  borderRadius,\n`;
  ts += `  shadows,\n`;
  ts += `  breakpoints,\n`;
  ts += `};\n`;

  return ts;
}

// Main execution
try {
  const tokens = JSON.parse(
    fs.readFileSync(path.join(__dirname, '../tokens.json'), 'utf8')
  );

  const ts = generateTypeScript(tokens);

  // Write to frontend config
  const outputPath = path.join(__dirname, '../../frontend/config/design-tokens.ts');

  // Create directory if it doesn't exist
  const dir = path.dirname(outputPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  fs.writeFileSync(outputPath, ts);

  console.log('✅ TypeScript tokens generated successfully!');
  console.log('📁 Output:', outputPath);
} catch (error) {
  console.error('❌ Error generating TypeScript tokens:', error.message);
  process.exit(1);
}

