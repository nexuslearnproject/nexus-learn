'use client';

import { useParams } from 'next/navigation';
import Link from 'next/link';
import { LanguageProvider, useLanguage } from '@/contexts/LanguageContext';
import { Navbar } from '@/components/layout';
import { Button, Badge, Card, CardContent } from '@/components/ui';
import { 
  Clock,
  Users,
  Star,
  BookOpen,
  Award,
  Play,
  CheckCircle2,
  ChevronRight,
} from 'lucide-react';

function CourseDetailContent() {
  const params = useParams();
  const courseId = params.id;
  const { t } = useLanguage();

  // Mock course data (in a real app, this would come from an API)
  const courses: { [key: string]: any } = {
    '1': {
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
      description: 'คอร์สเรียนรู้การเขียนโปรแกรมเชิงวัตถุขั้นสูง เหมาะสำหรับการสอบ GAT/PAT และการพัฒนาทักษะการเขียนโปรแกรม',
      lessons: 120,
      language: 'ไทย',
    },
    '2': {
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
      description: 'เรียนรู้การออกแบบ UI/UX และการใช้เครื่องมือออกแบบสำหรับการสร้างสรรค์ผลงานดิจิทัล',
      lessons: 110,
      language: 'ไทย',
    },
    '3': {
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
      description: 'เรียนรู้หลักการบริหารธุรกิจสมัยใหม่ รวมถึงการวิเคราะห์และการตัดสินใจเชิงกลยุทธ์',
      lessons: 90,
      language: 'ไทย',
    },
    '4': {
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
      description: 'เรียนรู้การวิเคราะห์ข้อมูลด้วย Python และเครื่องมือ Data Science ยอดนิยม',
      lessons: 100,
      language: 'ไทย',
    },
  };

  const course = courses[courseId as string] || courses['1'];

  const curriculum = [
    {
      section: 'บทที่ 1: แนะนำพื้นฐาน',
      lessons: [
        { title: 'บทนำและแนะนำคอร์ส', duration: '10 นาที', completed: false },
        { title: 'การติดตั้งเครื่องมือที่จำเป็น', duration: '15 นาที', completed: false },
        { title: 'โครงสร้างของโปรแกรม', duration: '20 นาที', completed: false },
      ],
    },
    {
      section: 'บทที่ 2: หลักการพื้นฐาน',
      lessons: [
        { title: 'ตัวแปรและชนิดข้อมูล', duration: '25 นาที', completed: false },
        { title: 'การควบคุมโปรแกรม', duration: '30 นาที', completed: false },
        { title: 'ฟังก์ชันและการใช้งาน', duration: '35 นาที', completed: false },
      ],
    },
    {
      section: 'บทที่ 3: แนวคิดขั้นสูง',
      lessons: [
        { title: 'Object-Oriented Programming', duration: '40 นาที', completed: false },
        { title: 'การจัดการข้อผิดพลาด', duration: '25 นาที', completed: false },
        { title: 'โปรเจกต์จริง', duration: '60 นาที', completed: false },
      ],
    },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      
      {/* Hero Section */}
      <section className="bg-gradient-to-r from-blue-600 to-purple-600 text-white py-12">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl">
            <div className="flex items-center gap-2 mb-4">
              <Link href="/courses" className="text-blue-100 hover:text-white transition-colors">
                คอร์สทั้งหมด
              </Link>
              <ChevronRight className="h-4 w-4" />
              <span className="text-blue-100">{course.category}</span>
            </div>
            
            <h1 className="text-4xl md:text-5xl font-bold mb-4">
              {course.title}
            </h1>
            
            <p className="text-xl text-blue-100 mb-6">
              {course.description}
            </p>
            
            <div className="flex flex-wrap items-center gap-4 mb-6">
              <div className="flex items-center gap-1">
                <Star className="h-5 w-5 fill-yellow-400 text-yellow-400" />
                <span className="font-bold">{course.rating}</span>
              </div>
              <div className="flex items-center gap-2">
                <Users className="h-5 w-5" />
                <span>{course.students.toLocaleString()} นักเรียน</span>
              </div>
              <div className="flex items-center gap-2">
                <Clock className="h-5 w-5" />
                <span>{course.duration}</span>
              </div>
              <div className="flex items-center gap-2">
                <BookOpen className="h-5 w-5" />
                <span>{course.lessons} บทเรียน</span>
              </div>
            </div>
            
            <div className="flex items-center gap-2 mb-4">
              <span>สอนโดย:</span>
              <span className="font-semibold">{course.instructor}</span>
            </div>
          </div>
        </div>
      </section>

      <section className="py-12">
        <div className="container mx-auto px-4">
          <div className="grid lg:grid-cols-3 gap-8">
            {/* Main Content */}
            <div className="lg:col-span-2 space-y-8">
              {/* What You'll Learn */}
              <Card>
                <CardContent className="p-6">
                  <h2 className="text-2xl font-bold mb-4">สิ่งที่คุณจะได้เรียนรู้</h2>
                  <div className="grid md:grid-cols-2 gap-3">
                    {[
                      'เข้าใจหลักการพื้นฐานอย่างลึกซึ้ง',
                      'สามารถพัฒนาโปรเจกต์จริงได้',
                      'ทักษะการแก้ปัญหาขั้นสูง',
                      'เทคนิคการเขียนโค้ดที่มีประสิทธิภาพ',
                      'การทำงานกับเครื่องมือยอดนิยม',
                      'พร้อมสำหรับการสอบและทำงาน',
                    ].map((item, index) => (
                      <div key={index} className="flex items-start gap-2">
                        <CheckCircle2 className="h-5 w-5 text-green-600 flex-shrink-0 mt-0.5" />
                        <span>{item}</span>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>

              {/* Curriculum */}
              <Card>
                <CardContent className="p-6">
                  <h2 className="text-2xl font-bold mb-4">เนื้อหาคอร์ส</h2>
                  <div className="space-y-4">
                    {curriculum.map((section, sectionIndex) => (
                      <div key={sectionIndex} className="border rounded-lg">
                        <div className="p-4 bg-gray-50 font-semibold flex items-center justify-between">
                          <span>{section.section}</span>
                          <span className="text-sm text-gray-600">
                            {section.lessons.length} บทเรียน
                          </span>
                        </div>
                        <div className="divide-y">
                          {section.lessons.map((lesson, lessonIndex) => (
                            <div
                              key={lessonIndex}
                              className="p-4 flex items-center justify-between hover:bg-gray-50 transition-colors"
                            >
                              <div className="flex items-center gap-3">
                                <Play className="h-4 w-4 text-gray-400" />
                                <span>{lesson.title}</span>
                              </div>
                              <span className="text-sm text-gray-600">{lesson.duration}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>

              {/* Instructor */}
              <Card>
                <CardContent className="p-6">
                  <h2 className="text-2xl font-bold mb-4">เกี่ยวกับผู้สอน</h2>
                  <div className="flex items-start gap-4">
                    <div className="h-20 w-20 rounded-full bg-blue-600 flex items-center justify-center text-white text-2xl font-bold flex-shrink-0">
                      {course.instructor.charAt(0)}
                    </div>
                    <div>
                      <h3 className="font-bold text-xl mb-1">{course.instructor}</h3>
                      <p className="text-gray-600 mb-3">
                        ผู้เชี่ยวชาญด้าน {course.category} พร้อมประสบการณ์การสอนกว่า 10 ปี
                      </p>
                      <div className="flex flex-wrap gap-4 text-sm">
                        <div className="flex items-center gap-1">
                          <Star className="h-4 w-4 text-yellow-500" />
                          <span>4.9 คะแนนผู้สอน</span>
                        </div>
                        <div className="flex items-center gap-1">
                          <Users className="h-4 w-4" />
                          <span>25,000+ นักเรียน</span>
                        </div>
                        <div className="flex items-center gap-1">
                          <BookOpen className="h-4 w-4" />
                          <span>15 คอร์ส</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>

            {/* Sidebar */}
            <div className="lg:col-span-1">
              <Card className="sticky top-20">
                <CardContent className="p-6">
                  <img
                    src={course.image}
                    alt={course.title}
                    className="w-full h-48 object-cover rounded-lg mb-4"
                  />
                  
                  <div className="mb-4">
                    <span className="text-3xl font-bold">{course.price}</span>
                  </div>
                  
                  <Button className="w-full mb-3" size="lg">
                    ลงทะเบียนเรียน
                  </Button>
                  
                  <Button variant="outline" className="w-full mb-6" size="lg">
                    เพิ่มในรายการโปรด
                  </Button>
                  
                  <div className="space-y-3 text-sm">
                    <div className="flex items-center justify-between">
                      <span className="text-gray-600">ระดับความยาก</span>
                      <Badge variant="secondary">{course.level}</Badge>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-gray-600">ระยะเวลา</span>
                      <span className="font-medium">{course.duration}</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-gray-600">จำนวนบทเรียน</span>
                      <span className="font-medium">{course.lessons} บท</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-gray-600">ภาษา</span>
                      <span className="font-medium">{course.language}</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-gray-600">นักเรียน</span>
                      <span className="font-medium">{course.students.toLocaleString()}</span>
                    </div>
                  </div>
                  
                  <div className="mt-6 pt-6 border-t">
                    <div className="flex items-center gap-2 text-sm text-gray-600 mb-2">
                      <Award className="h-4 w-4" />
                      <span>รับใบประกาศนียบัตรเมื่อเรียนจบ</span>
                    </div>
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                      <Clock className="h-4 w-4" />
                      <span>เข้าถึงเนื้อหาได้ตลอดชีพ</span>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
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

export default function CourseDetailPage() {
  return (
    <LanguageProvider>
      <CourseDetailContent />
    </LanguageProvider>
  );
}

