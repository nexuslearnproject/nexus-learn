'use client';

import Link from 'next/link';
import { LanguageProvider, useLanguage } from '@/contexts/LanguageContext';
import { Navbar } from '@/components/layout';
import { CourseCard } from '@/components/features/courses';
import { Button, Badge } from '@/components/ui';
import { 
  Filter,
  Search,
  ChevronDown,
} from 'lucide-react';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui';

function CoursesContent() {
  const { t } = useLanguage();

  // All courses data
  const allCourses = [
    {
      id: 1,
      title: t('course.1.title'),
      instructor: t('course.1.instructor'),
      image: 'https://images.unsplash.com/photo-1565229284535-2cbbe3049123?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb2RpbmclMjBwcm9ncmFtbWluZ3xlbnwxfHx8fDE3NjI4MjAyMTh8MA&ixlib=rb-4.1.0&q=80&w=1080',
      price: '฿2,990',
      rating: 4.9,
      students: 8500,
      duration: '60 ชั่วโมง',
      level: t('courses.level.advanced'),
      category: 'กพ',
    },
    {
      id: 2,
      title: t('course.2.title'),
      instructor: t('course.2.instructor'),
      image: 'https://images.unsplash.com/photo-1742440710226-450e3b85c100?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxkZXNpZ24lMjBjcmVhdGl2ZSUyMHdvcmtzcGFjZXxlbnwxfHx8fDE3NjI3NDU2NTR8MA&ixlib=rb-4.1.0&q=80&w=1080',
      price: '฿2,990',
      rating: 4.9,
      students: 7200,
      duration: '55 ชั่วโมง',
      level: t('courses.level.advanced'),
      category: 'กพ',
    },
    {
      id: 3,
      title: t('course.3.title'),
      instructor: t('course.3.instructor'),
      image: 'https://images.unsplash.com/photo-1709715357520-5e1047a2b691?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxidXNpbmVzcyUyMG1lZXRpbmd8ZW58MXx8fHwxNzYyNzQwNzA3fDA&ixlib=rb-4.1.0&q=80&w=1080',
      price: '฿1,990',
      rating: 4.8,
      students: 12500,
      duration: '45 ชั่วโมง',
      level: t('courses.level.intermediate'),
      category: 'คณิตศาสตร์',
    },
    {
      id: 4,
      title: t('course.4.title'),
      instructor: t('course.4.instructor'),
      image: 'https://images.unsplash.com/photo-1666875753105-c63a6f3bdc86?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxkYXRhJTIwc2NpZW5jZSUyMGFuYWx5dGljc3xlbnwxfHx8fDE3NjI3MTQ5MDJ8MA&ixlib=rb-4.1.0&q=80&w=1080',
      price: '฿1,990',
      rating: 4.8,
      students: 10800,
      duration: '50 ชั่วโมง',
      level: t('courses.level.intermediate'),
      category: 'วิทยาศาสตร์',
    },
    {
      id: 5,
      title: 'การเขียนโปรแกรม Python ขั้นสูง',
      instructor: 'อ.ธนพล วีระชัย',
      image: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
      price: '฿2,490',
      rating: 4.7,
      students: 6800,
      duration: '48 ชั่วโมง',
      level: t('courses.level.advanced'),
      category: 'กพ',
    },
    {
      id: 6,
      title: 'ฟิสิกส์มหภาค สำหรับ ม.ปลาย',
      instructor: 'ดร.สมชาย พันธุ์งาม',
      image: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
      price: '฿1,790',
      rating: 4.8,
      students: 5600,
      duration: '40 ชั่วโมง',
      level: t('courses.level.intermediate'),
      category: 'วิทยาศาสตร์',
    },
    {
      id: 7,
      title: 'ภาษาไทย วรรณคดีไทย',
      instructor: 'อ.สุดารัตน์ ศรีสุข',
      image: 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
      price: '฿1,490',
      rating: 4.6,
      students: 9200,
      duration: '35 ชั่วโมง',
      level: t('courses.level.beginner'),
      category: 'ภาษาไทย',
    },
    {
      id: 8,
      title: 'English Grammar Master Class',
      instructor: 'Prof. John Anderson',
      image: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
      price: '฿1,990',
      rating: 4.9,
      students: 11500,
      duration: '42 ชั่วโมง',
      level: t('courses.level.intermediate'),
      category: 'ภาษาอังกฤษ',
    },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      
      {/* Hero Section */}
      <section className="bg-gradient-to-r from-blue-600 to-purple-600 text-white py-16">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl">
            <h1 className="text-4xl md:text-5xl font-bold mb-4">
              {t('courses.title')}
            </h1>
            <p className="text-xl text-blue-100 mb-8">
              {t('courses.description')}
            </p>
            
            {/* Search Bar */}
            <div className="bg-white rounded-lg p-2 flex gap-2">
              <div className="flex-1 flex items-center gap-2 px-3">
                <Search className="h-5 w-5 text-gray-400" />
                <input
                  type="text"
                  placeholder="ค้นหาคอร์สที่คุณสนใจ..."
                  className="flex-1 outline-none text-gray-900"
                />
              </div>
              <Button size="lg">
                ค้นหา
              </Button>
            </div>
          </div>
        </div>
      </section>

      {/* Filters and Courses */}
      <section className="py-12">
        <div className="container mx-auto px-4">
          {/* Filter Bar */}
          <div className="flex flex-wrap gap-4 mb-8">
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" className="gap-2">
                  <Filter className="h-4 w-4" />
                  หมวดหมู่
                  <ChevronDown className="h-4 w-4" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent>
                <DropdownMenuItem>ทั้งหมด</DropdownMenuItem>
                <DropdownMenuItem>กพ (GAT/PAT)</DropdownMenuItem>
                <DropdownMenuItem>คณิตศาสตร์</DropdownMenuItem>
                <DropdownMenuItem>วิทยาศาสตร์</DropdownMenuItem>
                <DropdownMenuItem>ภาษาไทย</DropdownMenuItem>
                <DropdownMenuItem>ภาษาอังกฤษ</DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>

            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" className="gap-2">
                  ระดับความยาก
                  <ChevronDown className="h-4 w-4" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent>
                <DropdownMenuItem>ทั้งหมด</DropdownMenuItem>
                <DropdownMenuItem>{t('courses.level.beginner')}</DropdownMenuItem>
                <DropdownMenuItem>{t('courses.level.intermediate')}</DropdownMenuItem>
                <DropdownMenuItem>{t('courses.level.advanced')}</DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>

            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" className="gap-2">
                  เรียงตาม
                  <ChevronDown className="h-4 w-4" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent>
                <DropdownMenuItem>ยอดนิยม</DropdownMenuItem>
                <DropdownMenuItem>คะแนนสูงสุด</DropdownMenuItem>
                <DropdownMenuItem>ล่าสุด</DropdownMenuItem>
                <DropdownMenuItem>ราคาต่ำสุด</DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>

          {/* Courses Grid */}
          <div className="mb-6 flex items-center justify-between">
            <p className="text-gray-600">
              แสดง <strong>{allCourses.length}</strong> คอร์ส
            </p>
          </div>

          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {allCourses.map((course) => (
              <Link key={course.id} href={`/courses/${course.id}`}>
                <CourseCard {...course} />
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-gray-300 py-12 mt-16">
        <div className="container mx-auto px-4 text-center">
          <p className="text-sm">© 2024 Nexus Learn. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
}

export default function CoursesPage() {
  return (
    <LanguageProvider>
      <CoursesContent />
    </LanguageProvider>
  );
}

