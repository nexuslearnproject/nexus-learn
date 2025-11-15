import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: AppColors.neutralWhite,
          borderRadius: AppBorderRadius.xl,
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppBorderRadius.circularXl),
                topRight: Radius.circular(AppBorderRadius.circularXl),
              ),
              child: Stack(
                children: [
                  Image.network(
                    course['image'],
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 140,
                        color: AppColors.neutral200,
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.neutral400,
                        ),
                      );
                    },
                  ),
                  // Category Badge
                  Positioned(
                    top: AppSpacing.space2,
                    right: AppSpacing.space2,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.space2,
                        vertical: AppSpacing.space1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary500,
                        borderRadius: AppBorderRadius.md,
                      ),
                      child: Text(
                        course['category'],
                        style: TextStyle(
                          color: AppColors.neutralWhite,
                          fontSize: AppTypography.fontSizeXs,
                          fontWeight: AppTypography.fontWeightMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Course Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Level Badge and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.space2,
                            vertical: AppSpacing.space1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: AppBorderRadius.md,
                          ),
                          child: Text(
                            course['level'],
                            style: TextStyle(
                              fontSize: AppTypography.fontSizeXs,
                              color: AppColors.neutral700,
                              fontWeight: AppTypography.fontWeightMedium,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            SizedBox(width: AppSpacing.space1),
                            Text(
                              course['rating'].toString(),
                              style: TextStyle(
                                fontSize: AppTypography.fontSizeSm,
                                fontWeight: AppTypography.fontWeightSemibold,
                                color: AppColors.neutral900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: AppSpacing.space2),

                    // Course Title
                    Text(
                      course['title'],
                      style: TextStyle(
                        fontSize: AppTypography.fontSizeBase,
                        fontWeight: AppTypography.fontWeightSemibold,
                        color: AppColors.neutral900,
                        height: AppTypography.lineHeightTight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: AppSpacing.space1),

                    // Instructor
                    Text(
                      'โดย ${course['instructor']}',
                      style: TextStyle(
                        fontSize: AppTypography.fontSizeSm,
                        color: AppColors.neutral600,
                      ),
                    ),

                    const Spacer(),

                    // Course Stats
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.neutral500,
                        ),
                        SizedBox(width: AppSpacing.space1),
                        Text(
                          course['duration'],
                          style: TextStyle(
                            fontSize: AppTypography.fontSizeXs,
                            color: AppColors.neutral600,
                          ),
                        ),
                        SizedBox(width: AppSpacing.space3),
                        Icon(
                          Icons.people,
                          size: 14,
                          color: AppColors.neutral500,
                        ),
                        SizedBox(width: AppSpacing.space1),
                        Text(
                          '${course['students']}',
                          style: TextStyle(
                            fontSize: AppTypography.fontSizeXs,
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppSpacing.space3),

                    // Price and Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          course['price'],
                          style: TextStyle(
                            fontSize: AppTypography.fontSizeXl,
                            fontWeight: AppTypography.fontWeightBold,
                            color: AppColors.primary600,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary500,
                            foregroundColor: AppColors.neutralWhite,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.space4,
                              vertical: AppSpacing.space2,
                            ),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppBorderRadius.md,
                            ),
                          ),
                          child: Text(
                            'ดูรายละเอียด',
                            style: TextStyle(
                              fontSize: AppTypography.fontSizeSm,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

