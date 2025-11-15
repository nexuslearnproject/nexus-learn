import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';

class HeroSection extends StatefulWidget {
  final Function(String) onSearch;

  const HeroSection({
    super.key,
    required this.onSearch,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary50,
            AppColors.neutralWhite,
            AppColors.secondary50,
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.space3,
                vertical: AppSpacing.space2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary100,
                borderRadius: AppBorderRadius.full,
              ),
              child: Text(
                'แพลตฟอร์มการเรียนรู้ด้วย AI',
                style: TextStyle(
                  fontSize: AppTypography.fontSizeSm,
                  fontWeight: AppTypography.fontWeightMedium,
                  color: AppColors.primary700,
                ),
              ),
            ),

            SizedBox(height: AppSpacing.space4),

            // Main Title
            Text(
              'เรียนรู้กับ\nAI ที่เข้าใจคุณ',
              style: TextStyle(
                fontSize: AppTypography.fontSize4xl,
                fontWeight: AppTypography.fontWeightBold,
                color: AppColors.neutral900,
                height: AppTypography.lineHeightTight,
              ),
            ),

            SizedBox(height: AppSpacing.space2),

            // Subtitle
            Text(
              'คอร์สเรียนออนไลน์ที่ปรับระดับความยากให้เหมาะกับคุณ',
              style: TextStyle(
                fontSize: AppTypography.fontSizeBase,
                color: AppColors.neutral600,
                height: AppTypography.lineHeightRelaxed,
              ),
            ),

            SizedBox(height: AppSpacing.space6),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                borderRadius: AppBorderRadius.lg,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutral200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ค้นหาคอร์สที่คุณสนใจ...',
                  hintStyle: TextStyle(
                    color: AppColors.neutral400,
                    fontSize: AppTypography.fontSizeBase,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.neutral400,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.arrow_forward,
                      color: AppColors.primary500,
                    ),
                    onPressed: () {
                      if (_searchController.text.isNotEmpty) {
                        widget.onSearch(_searchController.text);
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.lg,
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.neutralWhite,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                    vertical: AppSpacing.space4,
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    widget.onSearch(value);
                  }
                },
              ),
            ),

            SizedBox(height: AppSpacing.space6),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('10K+', 'นักเรียน'),
                _buildStat('500+', 'คอร์ส'),
                _buildStat('50+', 'ผู้สอน AI'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: AppTypography.fontSize2xl,
            fontWeight: AppTypography.fontWeightBold,
            color: AppColors.primary600,
          ),
        ),
        SizedBox(height: AppSpacing.space1),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.fontSizeSm,
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }
}

