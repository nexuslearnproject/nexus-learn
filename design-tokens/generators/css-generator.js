const fs = require('fs');
const path = require('path');

function generateCSS(tokens) {
  let css = `/* Auto-generated from design tokens - DO NOT EDIT MANUALLY */\n/* Last generated: ${new Date().toISOString()} */\n\n`;
  css += `:root {\n`;

  // Colors
  Object.entries(tokens.colors).forEach(([category, shades]) => {
    if (typeof shades === 'object' && !Array.isArray(shades)) {
      Object.entries(shades).forEach(([shade, value]) => {
        css += `  --color-${category}-${shade}: ${value};\n`;
      });
    } else {
      css += `  --color-${category}: ${shades};\n`;
    }
  });

  css += `\n`;

  // Typography - Font Family
  Object.entries(tokens.typography.fontFamily).forEach(([name, value]) => {
    css += `  --font-family-${name}: ${value};\n`;
  });

  css += `\n`;

  // Typography - Font Size
  Object.entries(tokens.typography.fontSize).forEach(([size, value]) => {
    css += `  --font-size-${size}: ${value};\n`;
  });

  css += `\n`;

  // Typography - Font Weight
  Object.entries(tokens.typography.fontWeight).forEach(([weight, value]) => {
    css += `  --font-weight-${weight}: ${value};\n`;
  });

  css += `\n`;

  // Typography - Line Height
  Object.entries(tokens.typography.lineHeight).forEach(([name, value]) => {
    css += `  --line-height-${name}: ${value};\n`;
  });

  css += `\n`;

  // Spacing
  Object.entries(tokens.spacing).forEach(([key, value]) => {
    css += `  --spacing-${key}: ${value};\n`;
  });

  css += `\n`;

  // Border Radius
  Object.entries(tokens.borderRadius).forEach(([key, value]) => {
    css += `  --radius-${key}: ${value};\n`;
  });

  css += `\n`;

  // Shadows
  Object.entries(tokens.shadows).forEach(([key, value]) => {
    css += `  --shadow-${key}: ${value};\n`;
  });

  css += `\n`;

  // Breakpoints
  Object.entries(tokens.breakpoints).forEach(([key, value]) => {
    css += `  --breakpoint-${key}: ${value};\n`;
  });

  css += `}\n\n`;

  // Add utility classes
  css += `/* Utility Classes */\n`;
  css += `.container {\n`;
  css += `  width: 100%;\n`;
  css += `  margin-left: auto;\n`;
  css += `  margin-right: auto;\n`;
  css += `  padding-left: var(--spacing-4);\n`;
  css += `  padding-right: var(--spacing-4);\n`;
  css += `}\n\n`;

  css += `@media (min-width: var(--breakpoint-sm)) {\n`;
  css += `  .container { max-width: var(--breakpoint-sm); }\n`;
  css += `}\n\n`;

  css += `@media (min-width: var(--breakpoint-md)) {\n`;
  css += `  .container { max-width: var(--breakpoint-md); }\n`;
  css += `}\n\n`;

  css += `@media (min-width: var(--breakpoint-lg)) {\n`;
  css += `  .container { max-width: var(--breakpoint-lg); }\n`;
  css += `}\n\n`;

  css += `@media (min-width: var(--breakpoint-xl)) {\n`;
  css += `  .container { max-width: var(--breakpoint-xl); }\n`;
  css += `}\n`;

  return css;
}

// Main execution
try {
  const tokens = JSON.parse(
    fs.readFileSync(path.join(__dirname, '../tokens.json'), 'utf8')
  );

  const css = generateCSS(tokens);

  // Write to frontend styles
  const outputPath = path.join(__dirname, '../../frontend/styles/tokens.css');
  
  // Create directory if it doesn't exist
  const dir = path.dirname(outputPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  fs.writeFileSync(outputPath, css);

  console.log('✅ CSS tokens generated successfully!');
  console.log('📁 Output:', outputPath);
} catch (error) {
  console.error('❌ Error generating CSS tokens:', error.message);
  process.exit(1);
}

