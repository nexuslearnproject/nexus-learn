import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final int courses;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.courses,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.neutralWhite,
          borderRadius: AppBorderRadius.xl,
          border: Border.all(
            color: AppColors.neutral200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral200.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.space5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: AppBorderRadius.xl,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              
              SizedBox(height: AppSpacing.space3),
              
              // Category Title
              Text(
                title,
                style: TextStyle(
                  fontSize: AppTypography.fontSizeBase,
                  fontWeight: AppTypography.fontWeightSemibold,
                  color: AppColors.neutral900,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: AppSpacing.space1),
              
              // Course Count
              Text(
                '$courses คอร์ส',
                style: TextStyle(
                  fontSize: AppTypography.fontSizeSm,
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

