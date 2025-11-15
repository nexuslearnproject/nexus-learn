import 'package:flutter/material.dart';
import 'constants/design_tokens.dart';
import 'screens/landing_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Learn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Use design tokens for colors
        primaryColor: AppColors.primary500,
        scaffoldBackgroundColor: AppColors.neutralWhite,
        
        // Color scheme
        colorScheme: ColorScheme.light(
          primary: AppColors.primary500,
          secondary: AppColors.secondary500,
          error: AppColors.semanticError,
          surface: AppColors.neutralWhite,
          onPrimary: AppColors.neutralWhite,
          onSecondary: AppColors.neutralWhite,
          onSurface: AppColors.neutral900,
        ),
        
        // Typography using design tokens
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: AppTypography.fontSize5xl,
            fontWeight: AppTypography.fontWeightBold,
            color: AppColors.neutral900,
          ),
          displayMedium: TextStyle(
            fontSize: AppTypography.fontSize4xl,
            fontWeight: AppTypography.fontWeightBold,
            color: AppColors.neutral900,
          ),
          displaySmall: TextStyle(
            fontSize: AppTypography.fontSize3xl,
            fontWeight: AppTypography.fontWeightSemibold,
            color: AppColors.neutral900,
          ),
          headlineLarge: TextStyle(
            fontSize: AppTypography.fontSize2xl,
            fontWeight: AppTypography.fontWeightSemibold,
            color: AppColors.neutral900,
          ),
          headlineMedium: TextStyle(
            fontSize: AppTypography.fontSizeXl,
            fontWeight: AppTypography.fontWeightMedium,
            color: AppColors.neutral900,
          ),
          bodyLarge: TextStyle(
            fontSize: AppTypography.fontSizeBase,
            fontWeight: AppTypography.fontWeightNormal,
            color: AppColors.neutral900,
          ),
          bodyMedium: TextStyle(
            fontSize: AppTypography.fontSizeSm,
            fontWeight: AppTypography.fontWeightNormal,
            color: AppColors.neutral700,
          ),
        ),
        
        // App bar theme
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary500,
          foregroundColor: AppColors.neutralWhite,
          elevation: AppShadows.elevation2,
        ),
        
        // Card theme
        cardTheme: CardTheme(
          elevation: AppShadows.elevation1,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.lg,
          ),
        ),
        
        // Button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary500,
            foregroundColor: AppColors.neutralWhite,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space6,
              vertical: AppSpacing.space3,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.md,
            ),
          ),
        ),
        
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: AppBorderRadius.md,
          ),
          filled: true,
          fillColor: AppColors.neutral50,
        ),
      ),
      home: const LandingScreen(),
    );
  }
}
