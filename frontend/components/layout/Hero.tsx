'use client';

import { useRouter } from 'next/navigation';
import { Search, PlayCircle } from 'lucide-react';
import { Button, Badge } from '@/components/ui';
import { useLanguage } from '@/contexts/LanguageContext';
import { useState, useRef, useEffect } from 'react';

export function Hero() {
  const { t, language } = useLanguage();
  const router = useRouter();
  const [searchQuery, setSearchQuery] = useState('');
  const [showResults, setShowResults] = useState(false);
  const searchRef = useRef<HTMLDivElement>(null);

  // Mock course data for search
  const allCourses = [
    {
      id: 1,
      titleTh: 'ติวสอบ กพ ภาค ก. ด้วย AI แบบเข้มข้น',
      titleEn: 'กพ Part A - AI Intensive Course',
      category: 'กพ',
      categoryEn: 'Civil Service',
      level: 'ขั้นสูง',
      levelEn: 'Advanced',
      price: '฿4,990'
    },
    {
      id: 2,
      titleTh: 'ติวสอบ กพ ภาค ข. พิชิตข้อสอบด้วย AI',
      titleEn: 'กพ Part B - AI Problem Solving',
      category: 'กพ',
      categoryEn: 'Civil Service',
      level: 'ขั้นสูง',
      levelEn: 'Advanced',
      price: '฿5,990'
    },
    {
      id: 3,
      titleTh: 'คณิตศาสตร์ ม.ปลาย - AI ปรับระดับ',
      titleEn: 'High School Math - AI Adaptive',
      category: 'คณิตศาสตร์',
      categoryEn: 'Mathematics',
      level: 'เริ่มต้น',
      levelEn: 'Beginner',
      price: '฿3,990'
    },
    {
      id: 4,
      titleTh: 'วิทยาศาสตร์ ม.ปลาย - เรียนกับ AI',
      titleEn: 'High School Science - AI Learning',
      category: 'วิทยาศาสตร์',
      categoryEn: 'Science',
      level: 'เริ่มต้น',
      levelEn: 'Beginner',
      price: '฿4,490'
    },
  ];

  // Filter courses based on search query
  const filteredCourses = searchQuery.trim()
    ? allCourses.filter(course => {
        const searchLower = searchQuery.toLowerCase();
        const title = language === 'th' ? course.titleTh : course.titleEn;
        const category = language === 'th' ? course.category : course.categoryEn;
        const level = language === 'th' ? course.level : course.levelEn;
        
        return (
          title.toLowerCase().includes(searchLower) ||
          category.toLowerCase().includes(searchLower) ||
          level.toLowerCase().includes(searchLower)
        );
      })
    : [];

  // Close dropdown when clicking outside
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (searchRef.current && !searchRef.current.contains(event.target as Node)) {
        setShowResults(false);
      }
    }
    
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setSearchQuery(e.target.value);
    setShowResults(true);
  };

  const handleCourseClick = (courseId: number) => {
    router.push(`/courses/${courseId}`);
    setSearchQuery('');
    setShowResults(false);
  };

  const handleSearch = () => {
    if (filteredCourses.length > 0) {
      handleCourseClick(filteredCourses[0].id);
    }
  };
  
  return (
    <div className="relative bg-gradient-to-br from-blue-50 via-white to-purple-50 overflow-hidden">
      <div className="container mx-auto px-4 py-16 md:py-24">
        <div className="grid md:grid-cols-2 gap-12 items-center">
          {/* Left Content */}
          <div className="space-y-6">
            <div className="inline-block px-4 py-2 bg-blue-100 text-blue-700 rounded-full text-sm font-medium">
              {t('hero.badge')}
            </div>
            <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold">
              {t('hero.title')}{' '}
              <span className="text-blue-600">{t('hero.titleHighlight')}</span>
            </h1>
            <p className="text-lg text-gray-600">
              {t('hero.description')}
            </p>
            
            {/* Search Bar */}
            <div className="flex flex-col sm:flex-row gap-3 pt-4">
              <div className="flex-1 relative" ref={searchRef}>
                <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400 z-10" />
                <input
                  type="text"
                  placeholder={t('hero.searchPlaceholder')}
                  className="w-full pl-12 pr-4 py-4 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={searchQuery}
                  onChange={handleSearchChange}
                  onFocus={() => searchQuery && setShowResults(true)}
                />
                
                {/* Search Results Dropdown */}
                {showResults && searchQuery.trim() && (
                  <div className="absolute left-0 right-0 top-full mt-2 bg-white border rounded-lg shadow-xl max-h-96 overflow-y-auto z-50">
                    {filteredCourses.length > 0 ? (
                      <div className="py-2">
                        <div className="px-4 py-2 text-xs text-gray-500 border-b">
                          {language === 'th' 
                            ? `พบ ${filteredCourses.length} คอร์ส` 
                            : `Found ${filteredCourses.length} courses`}
                        </div>
                        {filteredCourses.map(course => (
                          <div
                            key={course.id}
                            className="px-4 py-3 hover:bg-blue-50 cursor-pointer transition-colors border-b last:border-b-0"
                            onClick={() => handleCourseClick(course.id)}
                          >
                            <div className="flex items-start justify-between gap-3">
                              <div className="flex-1 min-w-0">
                                <h4 className="text-sm font-medium text-gray-900 mb-1 line-clamp-2">
                                  {language === 'th' ? course.titleTh : course.titleEn}
                                </h4>
                                <div className="flex items-center gap-2 flex-wrap">
                                  <Badge variant="outline" className="text-xs">
                                    {language === 'th' ? course.category : course.categoryEn}
                                  </Badge>
                                  <span className="text-xs text-gray-500">
                                    {language === 'th' ? course.level : course.levelEn}
                                  </span>
                                </div>
                              </div>
                              <div className="text-sm text-blue-600 shrink-0 font-semibold">
                                {course.price}
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    ) : (
                      <div className="px-4 py-8 text-center text-gray-500">
                        <Search className="h-12 w-12 mx-auto mb-3 text-gray-300" />
                        <p className="text-sm">
                          {language === 'th' 
                            ? 'ไม่พบคอร์สที่ค้นหา' 
                            : 'No courses found'}
                        </p>
                        <p className="text-xs text-gray-400 mt-1">
                          {language === 'th' 
                            ? 'ลองค้นหาด้วยคำอื่น' 
                            : 'Try searching with different keywords'}
                        </p>
                      </div>
                    )}
                  </div>
                )}
              </div>
              <Button size="lg" className="sm:w-auto" onClick={handleSearch}>
                {t('hero.searchButton')}
              </Button>
            </div>

            {/* Stats */}
            <div className="flex flex-wrap gap-8 pt-6">
              <div>
                <div className="text-3xl text-blue-600 font-bold">10K+</div>
                <div className="text-sm text-gray-600">{t('hero.stats.students')}</div>
              </div>
              <div>
                <div className="text-3xl text-blue-600 font-bold">500+</div>
                <div className="text-sm text-gray-600">{t('hero.stats.courses')}</div>
              </div>
              <div>
                <div className="text-3xl text-blue-600 font-bold">50+</div>
                <div className="text-sm text-gray-600">{t('hero.stats.instructors')}</div>
              </div>
            </div>
          </div>

          {/* Right Image */}
          <div className="relative hidden md:block">
            <div className="aspect-square rounded-2xl overflow-hidden shadow-2xl">
              <img
                src="https://images.unsplash.com/photo-1758874573138-f3dd1ed25c7e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzdHVkZW50cyUyMGxlYXJuaW5nJTIwb25saW5lfGVufDF8fHx8MTc2Mjc2MzE5OHww&ixlib=rb-4.1.0&q=80&w=1080"
                alt="Students learning online"
                className="w-full h-full object-cover"
              />
            </div>
            {/* Floating Card */}
            <div className="absolute bottom-6 left-6 bg-white p-4 rounded-lg shadow-lg flex items-center gap-3">
              <div className="h-12 w-12 bg-green-100 rounded-full flex items-center justify-center">
                <PlayCircle className="h-6 w-6 text-green-600" />
              </div>
              <div>
                <div className="text-sm text-gray-600">{t('hero.completion')}</div>
                <div className="font-semibold">{t('hero.successRate')}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

