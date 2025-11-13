const fs = require('fs');
const path = require('path');

function hexToFlutterColor(hex) {
  const color = hex.replace('#', '');
  return `Color(0xFF${color})`;
}

function remToPx(rem) {
  return parseFloat(rem) * 16;
}

function generateDart(tokens) {
  let dart = `// Auto-generated from design tokens - DO NOT EDIT MANUALLY\n`;
  dart += `// Last generated: ${new Date().toISOString()}\n\n`;
  dart += `import 'package:flutter/material.dart';\n\n`;

  // Colors Class
  dart += `/// Design system colors\n`;
  dart += `class AppColors {\n`;
  dart += `  AppColors._(); // Private constructor to prevent instantiation\n\n`;

  Object.entries(tokens.colors).forEach(([category, shades]) => {
    if (typeof shades === 'object' && !Array.isArray(shades)) {
      dart += `  // ${category.charAt(0).toUpperCase() + category.slice(1)} colors\n`;
      Object.entries(shades).forEach(([shade, value]) => {
        const varName = `${category}${shade.charAt(0).toUpperCase() + shade.slice(1)}`;
        dart += `  static const ${varName} = ${hexToFlutterColor(value)};\n`;
      });
      dart += `\n`;
    } else {
      dart += `  static const ${category} = ${hexToFlutterColor(shades)};\n`;
    }
  });

  dart += `}\n\n`;

  // Typography Class
  dart += `/// Design system typography\n`;
  dart += `class AppTypography {\n`;
  dart += `  AppTypography._();\n\n`;

  // Font Families
  dart += `  // Font families\n`;
  Object.entries(tokens.typography.fontFamily).forEach(([name, value]) => {
    const families = value.split(',')[0].trim().replace(/['"]/g, '');
    dart += `  static const fontFamily${name.charAt(0).toUpperCase() + name.slice(1)} = '${families}';\n`;
  });
  dart += `\n`;

  // Font Sizes
  dart += `  // Font sizes (in logical pixels)\n`;
  Object.entries(tokens.typography.fontSize).forEach(([size, value]) => {
    const numValue = remToPx(value);
    const varName = size === 'base' ? 'fontSizeBase' : `fontSize${size.charAt(0).toUpperCase() + size.slice(1)}`;
    dart += `  static const ${varName} = ${numValue.toFixed(1)};\n`;
  });
  dart += `\n`;

  // Font Weights
  dart += `  // Font weights\n`;
  Object.entries(tokens.typography.fontWeight).forEach(([weight, value]) => {
    const dartWeight = {
      '300': 'FontWeight.w300',
      '400': 'FontWeight.w400',
      '500': 'FontWeight.w500',
      '600': 'FontWeight.w600',
      '700': 'FontWeight.w700',
      '800': 'FontWeight.w800',
    }[value] || `FontWeight.w${value}`;
    
    dart += `  static const fontWeight${weight.charAt(0).toUpperCase() + weight.slice(1)} = ${dartWeight};\n`;
  });
  dart += `\n`;

  // Line Heights
  dart += `  // Line heights\n`;
  Object.entries(tokens.typography.lineHeight).forEach(([name, value]) => {
    dart += `  static const lineHeight${name.charAt(0).toUpperCase() + name.slice(1)} = ${value};\n`;
  });

  dart += `}\n\n`;

  // Spacing Class
  dart += `/// Design system spacing\n`;
  dart += `class AppSpacing {\n`;
  dart += `  AppSpacing._();\n\n`;

  Object.entries(tokens.spacing).forEach(([key, value]) => {
    const numValue = value === '0' ? 0 : remToPx(value);
    dart += `  static const space${key} = ${numValue.toFixed(1)};\n`;
  });

  dart += `}\n\n`;

  // Border Radius Class
  dart += `/// Design system border radius\n`;
  dart += `class AppBorderRadius {\n`;
  dart += `  AppBorderRadius._();\n\n`;

  Object.entries(tokens.borderRadius).forEach(([key, value]) => {
    if (value === '9999px') {
      dart += `  static const ${key} = BorderRadius.all(Radius.circular(9999));\n`;
    } else if (value === '0') {
      dart += `  static const ${key} = BorderRadius.zero;\n`;
    } else {
      const numValue = remToPx(value);
      dart += `  static const ${key} = BorderRadius.all(Radius.circular(${numValue.toFixed(1)}));\n`;
    }
  });

  dart += `\n`;

  // Add circular variants
  dart += `  // Circular radius values\n`;
  Object.entries(tokens.borderRadius).forEach(([key, value]) => {
    if (value !== '9999px' && value !== '0') {
      const numValue = remToPx(value);
      dart += `  static const circular${key.charAt(0).toUpperCase() + key.slice(1)} = ${numValue.toFixed(1)};\n`;
    }
  });

  dart += `}\n\n`;

  // Shadows Class
  dart += `/// Design system shadows\n`;
  dart += `class AppShadows {\n`;
  dart += `  AppShadows._();\n\n`;
  dart += `  // Note: Flutter shadows are defined inline\n`;
  dart += `  // Use BoxShadow with these elevation-like values:\n`;
  dart += `  static const elevation1 = 1.0;\n`;
  dart += `  static const elevation2 = 2.0;\n`;
  dart += `  static const elevation3 = 3.0;\n`;
  dart += `  static const elevation4 = 4.0;\n`;
  dart += `  static const elevation6 = 6.0;\n`;
  dart += `  static const elevation8 = 8.0;\n`;
  dart += `}\n`;

  return dart;
}

// Main execution
try {
  const tokens = JSON.parse(
    fs.readFileSync(path.join(__dirname, '../tokens.json'), 'utf8')
  );

  const dart = generateDart(tokens);

  // Write to mobile lib
  const outputPath = path.join(__dirname, '../../mobile/lib/constants/design_tokens.dart');

  // Create directory if it doesn't exist
  const dir = path.dirname(outputPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  fs.writeFileSync(outputPath, dart);

  console.log('✅ Dart tokens generated successfully!');
  console.log('📁 Output:', outputPath);
} catch (error) {
  console.error('❌ Error generating Dart tokens:', error.message);
  process.exit(1);
}

