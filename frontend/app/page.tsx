'use client';

import Link from 'next/link';
import { LanguageProvider, useLanguage } from '@/contexts/LanguageContext';
import { Navbar, Hero } from '@/components/layout';
import { CourseCard, CategoryCard } from '@/components/features/courses';
import { TestimonialCard } from '@/components/features/testimonials';
import { Button } from '@/components/ui';
import { 
  GraduationCap, 
  Calculator, 
  Microscope, 
  BookOpen, 
  Globe, 
  Map,
  Facebook,
  Twitter,
  Instagram,
  Linkedin,
  Mail,
} from 'lucide-react';

function AppContent() {
  const { t } = useLanguage();

  const courses = [
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
  ];

  const categories = [
    { title: t('category.civil'), courses: 245, icon: GraduationCap, color: 'bg-blue-600' },
    { title: t('category.math'), courses: 189, icon: Calculator, color: 'bg-purple-600' },
    { title: t('category.science'), courses: 167, icon: Microscope, color: 'bg-green-600' },
    { title: t('category.thai'), courses: 134, icon: BookOpen, color: 'bg-orange-600' },
    { title: t('category.english'), courses: 156, icon: Globe, color: 'bg-pink-600' },
    { title: t('category.social'), courses: 98, icon: Map, color: 'bg-indigo-600' },
  ];

  const testimonials = [
    {
      name: t('testimonial.1.name'),
      role: t('testimonial.1.role'),
      content: t('testimonial.1.content'),
      rating: 5,
      initials: 'AM',
    },
    {
      name: t('testimonial.2.name'),
      role: t('testimonial.2.role'),
      content: t('testimonial.2.content'),
      rating: 5,
      initials: 'RK',
    },
    {
      name: t('testimonial.3.name'),
      role: t('testimonial.3.role'),
      content: t('testimonial.3.content'),
      rating: 5,
      initials: 'DT',
    },
  ];

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      <Hero />
      
      {/* Featured Courses */}
      <section id="courses" className="py-16 md:py-24 bg-gray-50">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl mb-4 font-bold">
              {t('courses.title')}
            </h2>
            <p className="text-lg text-gray-600 max-w-2xl mx-auto">
              {t('courses.description')}
            </p>
          </div>
          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            {courses.map((course) => (
              <CourseCard key={course.id} {...course} />
            ))}
          </div>
          <div className="text-center">
            <Link href="/courses">
              <Button size="lg" variant="outline">
                {t('courses.viewAll')}
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* Categories */}
      <section id="categories" className="py-16 md:py-24">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl mb-4 font-bold">
              {t('categories.title')}
            </h2>
            <p className="text-lg text-gray-600 max-w-2xl mx-auto">
              {t('categories.description')}
            </p>
          </div>
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4 md:gap-6">
            {categories.map((category) => (
              <CategoryCard key={category.title} {...category} />
            ))}
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <section className="py-16 md:py-24 bg-blue-600 text-white">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl mb-4 font-bold">
              {t('testimonials.title')}
            </h2>
            <p className="text-lg text-blue-100 max-w-2xl mx-auto">
              {t('testimonials.description')}
            </p>
          </div>
          <div className="grid md:grid-cols-3 gap-6">
            {testimonials.map((testimonial) => (
              <TestimonialCard key={testimonial.name} {...testimonial} />
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 md:py-24 bg-gradient-to-r from-blue-600 to-purple-600 text-white">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl md:text-4xl mb-4 font-bold">
            {t('cta.title')}
          </h2>
          <p className="text-lg text-blue-100 max-w-2xl mx-auto mb-8">
            {t('cta.description')}
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link href="/courses">
              <Button size="lg" variant="secondary">
                {t('cta.browseCourses')}
              </Button>
            </Link>
            <Link href="/#contact">
              <Button size="lg" variant="outline" className="bg-transparent text-white border-white hover:bg-white hover:text-blue-600">
                {t('cta.becomeInstructor')}
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer id="contact" className="bg-gray-900 text-gray-300 py-12 md:py-16">
        <div className="container mx-auto px-4">
          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-8 mb-8">
            <div>
              <div className="flex items-center gap-2 mb-4 text-white">
                <span className="text-xl font-semibold">Nexus Learn</span>
              </div>
              <p className="text-sm mb-4">
                {t('footer.description')}
              </p>
              <div className="flex gap-3">
                <a href="#" className="hover:text-white transition-colors">
                  <Facebook className="h-5 w-5" />
                </a>
                <a href="#" className="hover:text-white transition-colors">
                  <Twitter className="h-5 w-5" />
                </a>
                <a href="#" className="hover:text-white transition-colors">
                  <Instagram className="h-5 w-5" />
                </a>
                <a href="#" className="hover:text-white transition-colors">
                  <Linkedin className="h-5 w-5" />
                </a>
              </div>
            </div>
            <div>
              <h3 className="text-white mb-4 font-semibold">{t('footer.quickLinks')}</h3>
              <ul className="space-y-2 text-sm">
                <li><a href="#" className="hover:text-white transition-colors">{t('footer.aboutUs')}</a></li>
                <li><a href="#" className="hover:text-white transition-colors">{t('footer.careers')}</a></li>
                <li><a href="#" className="hover:text-white transition-colors">{t('footer.blog')}</a></li>
                <li><a href="#" className="hover:text-white transition-colors">{t('footer.contact')}</a></li>
              </ul>
            </div>
            <div>
              <h3 className="text-white mb-4 font-semibold">{t('footer.support')}</h3>
              <ul className="space-y-2 text-sm">
                <li><a href="#" className="hover:text-white transition-colors">{t('footer.helpCenter')}</a></li>
                <li><a href="#" className="hover:text-white transition-colors">{t('footer.terms')}</a></li>
                <li><a href="#" className="hover:text-white transition-colors">{t('footer.privacy')}</a></li>
                <li><a href="#" className="hover:text-white transition-colors">{t('footer.accessibility')}</a></li>
              </ul>
            </div>
            <div>
              <h3 className="text-white mb-4 font-semibold">{t('footer.newsletter')}</h3>
              <p className="text-sm mb-4">{t('footer.newsletterDescription')}</p>
              <div className="flex gap-2">
                <input
                  type="email"
                  placeholder={t('footer.emailPlaceholder')}
                  className="flex-1 px-3 py-2 bg-gray-800 border border-gray-700 rounded text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 text-white placeholder-gray-400"
                />
                <Button size="sm">
                  <Mail className="h-4 w-4" />
                </Button>
              </div>
            </div>
          </div>
          <div className="border-t border-gray-800 pt-8 text-center text-sm">
            <p>{t('footer.copyright')}</p>
          </div>
        </div>
      </footer>
    </div>
  );
}

export default function HomePage() {
  return (
    <LanguageProvider>
      <AppContent />
    </LanguageProvider>
  );
}
