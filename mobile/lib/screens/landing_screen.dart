import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';
import '../widgets/course_card.dart';
import '../widgets/category_card.dart';
import '../widgets/hero_section.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();

  // Mock data - in production, this would come from API
  final List<Map<String, dynamic>> featuredCourses = [
    {
      'id': 1,
      'title': 'ติวสอบ กพ ภาค ก. ด้วย AI แบบเข้มข้น',
      'instructor': 'AI Instructor',
      'image': 'https://images.unsplash.com/photo-1565229284535-2cbbe3049123?w=400',
      'price': '฿2,990',
      'rating': 4.9,
      'students': 8500,
      'duration': '60 ชั่วโมง',
      'level': 'ขั้นสูง',
      'category': 'กพ',
    },
    {
      'id': 2,
      'title': 'ออกแบบ UI/UX ด้วย AI',
      'instructor': 'AI Instructor',
      'image': 'https://images.unsplash.com/photo-1742440710226-450e3b85c100?w=400',
      'price': '฿2,990',
      'rating': 4.9,
      'students': 7200,
      'duration': '55 ชั่วโมง',
      'level': 'ขั้นสูง',
      'category': 'กพ',
    },
    {
      'id': 3,
      'title': 'คณิตศาสตร์ ม.ปลาย - AI ปรับระดับ',
      'instructor': 'AI Instructor',
      'image': 'https://images.unsplash.com/photo-1709715357520-5e1047a2b691?w=400',
      'price': '฿1,990',
      'rating': 4.8,
      'students': 12500,
      'duration': '45 ชั่วโมง',
      'level': 'ปานกลาง',
      'category': 'คณิตศาสตร์',
    },
    {
      'id': 4,
      'title': 'วิทยาศาสตร์ Data Science',
      'instructor': 'AI Instructor',
      'image': 'https://images.unsplash.com/photo-1666875753105-c63a6f3bdc86?w=400',
      'price': '฿1,990',
      'rating': 4.8,
      'students': 10800,
      'duration': '50 ชั่วโมง',
      'level': 'ปานกลาง',
      'category': 'วิทยาศาสตร์',
    },
  ];

  final List<Map<String, dynamic>> categories = [
    {'title': 'กพ', 'courses': 245, 'icon': Icons.school, 'color': AppColors.primary500},
    {'title': 'คณิตศาสตร์', 'courses': 189, 'icon': Icons.calculate, 'color': AppColors.secondary500},
    {'title': 'วิทยาศาสตร์', 'courses': 167, 'icon': Icons.science, 'color': AppColors.semanticSuccess},
    {'title': 'ภาษาไทย', 'courses': 134, 'icon': Icons.menu_book, 'color': Colors.orange},
    {'title': 'ภาษาอังกฤษ', 'courses': 156, 'icon': Icons.language, 'color': Colors.pink},
    {'title': 'สังคมศึกษา', 'courses': 98, 'icon': Icons.map, 'color': AppColors.primary700},
  ];

  final List<Map<String, dynamic>> testimonials = [
    {
      'name': 'สมชาย ใจดี',
      'role': 'นักเรียน ม.6',
      'content': 'คอร์สนี้ช่วยให้ผมสอบติดมหาวิทยาลัยที่ต้องการได้จริงๆ AI สอนเข้าใจง่ายมาก',
      'rating': 5,
      'initials': 'สช',
    },
    {
      'name': 'สมหญิง รักเรียน',
      'role': 'นักเรียน ม.5',
      'content': 'ชอบที่ AI ปรับระดับความยากให้เหมาะกับเรา เรียนแล้วไม่เบื่อเลย',
      'rating': 5,
      'initials': 'สญ',
    },
    {
      'name': 'วิชัย เก่งมาก',
      'role': 'นักเรียน ม.6',
      'content': 'เรียนกับ AI สะดวกมาก เรียนได้ทุกที่ทุกเวลา แนะนำเลย!',
      'rating': 5,
      'initials': 'วช',
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.primary500,
            foregroundColor: AppColors.neutralWhite,
            elevation: AppShadows.elevation2,
            title: const Text(
              'Nexus Learn',
              style: TextStyle(
                fontWeight: AppTypography.fontWeightBold,
                fontSize: AppTypography.fontSizeXl,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // TODO: Implement search
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {
                  // TODO: Navigate to profile
                },
              ),
            ],
          ),

          // Hero Section
          SliverToBoxAdapter(
            child: HeroSection(
              onSearch: (query) {
                // TODO: Navigate to search results
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ค้นหา: $query')),
                );
              },
            ),
          ),

          // Featured Courses Section
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              title: 'คอร์สยอดนิยม',
              subtitle: 'คอร์สที่นักเรียนเลือกเรียนมากที่สุด',
              onSeeAll: () {
                // TODO: Navigate to courses page
              },
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
                itemCount: featuredCourses.length,
                itemBuilder: (context, index) {
                  final course = featuredCourses[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: AppSpacing.space4,
                      bottom: AppSpacing.space4,
                    ),
                    child: CourseCard(
                      course: course,
                      onTap: () {
                        // TODO: Navigate to course detail
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('เปิดคอร์ส: ${course['title']}')),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Categories Section
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              title: 'หมวดหมู่',
              subtitle: 'เลือกเรียนตามความสนใจ',
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.all(AppSpacing.space4),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: AppSpacing.space4,
                mainAxisSpacing: AppSpacing.space4,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = categories[index];
                  return CategoryCard(
                    title: category['title'],
                    courses: category['courses'],
                    icon: category['icon'],
                    color: category['color'],
                    onTap: () {
                      // TODO: Navigate to category courses
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('หมวดหมู่: ${category['title']}')),
                      );
                    },
                  );
                },
                childCount: categories.length,
              ),
            ),
          ),

          // Testimonials Section
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.primary500,
              padding: EdgeInsets.symmetric(vertical: AppSpacing.space8),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
                    child: Column(
                      children: [
                        Text(
                          'รีวิวจากนักเรียน',
                          style: TextStyle(
                            fontSize: AppTypography.fontSize2xl,
                            fontWeight: AppTypography.fontWeightBold,
                            color: AppColors.neutralWhite,
                          ),
                        ),
                        SizedBox(height: AppSpacing.space2),
                        Text(
                          'นักเรียนที่เรียนกับเรา',
                          style: TextStyle(
                            fontSize: AppTypography.fontSizeBase,
                            color: AppColors.primary100,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.space6),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
                      itemCount: testimonials.length,
                      itemBuilder: (context, index) {
                        final testimonial = testimonials[index];
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          margin: EdgeInsets.only(right: AppSpacing.space4),
                          padding: EdgeInsets.all(AppSpacing.space5),
                          decoration: BoxDecoration(
                            color: AppColors.neutralWhite,
                            borderRadius: AppBorderRadius.xl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: AppColors.primary100,
                                    child: Text(
                                      testimonial['initials'],
                                      style: TextStyle(
                                        color: AppColors.primary700,
                                        fontWeight: AppTypography.fontWeightSemibold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.space3),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          testimonial['name'],
                                          style: TextStyle(
                                            fontWeight: AppTypography.fontWeightSemibold,
                                            fontSize: AppTypography.fontSizeBase,
                                          ),
                                        ),
                                        Text(
                                          testimonial['role'],
                                          style: TextStyle(
                                            fontSize: AppTypography.fontSizeSm,
                                            color: AppColors.neutral600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                      testimonial['rating'],
                                      (index) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.space3),
                              Expanded(
                                child: Text(
                                  testimonial['content'],
                                  style: TextStyle(
                                    fontSize: AppTypography.fontSizeSm,
                                    color: AppColors.neutral700,
                                    height: AppTypography.lineHeightRelaxed,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CTA Section
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(AppSpacing.space8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary500, AppColors.secondary500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'พร้อมเริ่มเรียนแล้วหรือยัง?',
                    style: TextStyle(
                      fontSize: AppTypography.fontSize2xl,
                      fontWeight: AppTypography.fontWeightBold,
                      color: AppColors.neutralWhite,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.space2),
                  Text(
                    'เริ่มต้นการเรียนรู้กับ AI วันนี้',
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeBase,
                      color: AppColors.primary100,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.space6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to courses
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neutralWhite,
                          foregroundColor: AppColors.primary600,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.space8,
                            vertical: AppSpacing.space4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppBorderRadius.lg,
                          ),
                        ),
                        child: const Text('ดูคอร์สทั้งหมด'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(AppSpacing.space6),
              color: AppColors.neutral900,
              child: Column(
                children: [
                  Text(
                    'Nexus Learn',
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeXl,
                      fontWeight: AppTypography.fontWeightBold,
                      color: AppColors.neutralWhite,
                    ),
                  ),
                  SizedBox(height: AppSpacing.space2),
                  Text(
                    'แพลตฟอร์มการเรียนรู้ด้วย AI',
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeSm,
                      color: AppColors.neutral400,
                    ),
                  ),
                  SizedBox(height: AppSpacing.space4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.facebook, color: AppColors.neutral400),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.email, color: AppColors.neutral400),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.language, color: AppColors.neutral400),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.space4),
                  Text(
                    '© 2024 Nexus Learn. All rights reserved.',
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeXs,
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    String? subtitle,
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.space4,
        AppSpacing.space8,
        AppSpacing.space4,
        AppSpacing.space4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTypography.fontSize2xl,
                    fontWeight: AppTypography.fontWeightBold,
                    color: AppColors.neutral900,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppSpacing.space1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppTypography.fontSizeSm,
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'ดูทั้งหมด',
                style: TextStyle(
                  color: AppColors.primary600,
                  fontWeight: AppTypography.fontWeightMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

