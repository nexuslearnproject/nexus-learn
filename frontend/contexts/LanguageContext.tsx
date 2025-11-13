'use client';

import { createContext, useContext, useState, ReactNode } from 'react';

type Language = 'en' | 'th';

interface LanguageContextType {
  language: Language;
  setLanguage: (lang: Language) => void;
  t: (key: string) => string;
  toggle: () => void;
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

const translations = {
  en: {
    // Navbar
    'nav.courses': 'Courses',
    'nav.categories': 'Categories',
    'nav.about': 'About',
    'nav.contact': 'Contact',
    'nav.signIn': 'Sign In',
    'nav.getStarted': 'Get Started',
    
    // Hero
    'hero.badge': '🤖 AI-Powered Tutoring Platform',
    'hero.title': 'Master Your Exams with',
    'hero.titleHighlight': 'AI-Powered Learning',
    'hero.description': 'Advanced AI tutoring system for government exams (กพ) and high school students. Learn smarter with personalized AI that adapts to your learning pace and identifies your weak points.',
    'hero.searchPlaceholder': 'What do you want to learn?',
    'hero.searchButton': 'Search Courses',
    'hero.stats.students': 'Active Students',
    'hero.stats.courses': 'AI Courses',
    'hero.stats.instructors': 'AI Tutors',
    'hero.completion': 'AI Analysis',
    'hero.successRate': '24/7 Available',
    
    // Courses
    'courses.title': 'AI-Powered Courses',
    'courses.description': 'Explore our AI tutoring courses with intelligent learning paths',
    'courses.viewAll': 'View All Courses',
    'courses.enrollNow': 'Start Learning',
    'courses.by': 'powered by',
    'courses.level.beginner': 'Beginner',
    'courses.level.intermediate': 'Intermediate',
    'courses.level.advanced': 'Advanced',
    
    // Course Details
    'course.1.title': 'กพ Part A - AI Intensive Course',
    'course.1.instructor': 'AI Tutor Pro',
    'course.2.title': 'กพ Part B - AI Problem Solving',
    'course.2.instructor': 'AI Tutor Pro',
    'course.3.title': 'High School Math - AI Adaptive',
    'course.3.instructor': 'AI Math Master',
    'course.4.title': 'High School Science - AI Learning',
    'course.4.instructor': 'AI Science Expert',
    
    // Categories
    'categories.title': 'Browse by Category',
    'categories.description': 'Find the perfect AI course for your needs',
    'category.civil': 'Civil Service Exam (กพ)',
    'category.math': 'Mathematics',
    'category.science': 'Science',
    'category.thai': 'Thai Language',
    'category.english': 'English',
    'category.social': 'Social Studies',
    'category.coursesCount': 'AI Courses',
    
    // Testimonials
    'testimonials.title': 'Success Stories',
    'testimonials.description': 'Students who succeeded with our AI tutoring system',
    'testimonial.1.name': 'Somying Jaidee',
    'testimonial.1.role': 'Chulalongkorn University Student',
    'testimonial.1.content': 'The AI tutor analyzed my weak points and created a personalized study plan. I could practice 24/7 and got into my dream university!',
    'testimonial.2.name': 'Nattapol Rakrian',
    'testimonial.2.role': 'Government Official - Revenue Dept',
    'testimonial.2.content': 'The AI system for กพ exam was incredible. It adapted to my learning speed and focused on topics I struggled with. Passed with high scores!',
    'testimonial.3.name': 'Wanna Riandee',
    'testimonial.3.role': 'Grade 12 Student',
    'testimonial.3.content': 'Learning with AI is amazing! I can study anytime, get instant feedback, and the system knows exactly what I need to improve.',
    
    // CTA
    'cta.title': 'Ready to Learn with AI?',
    'cta.description': 'Join thousands of students learning smarter with our AI-powered tutoring system',
    'cta.browseCourses': 'Browse AI Courses',
    'cta.becomeInstructor': 'Partner with Us',
    
    // Footer
    'footer.description': 'Thailand\'s first AI-powered tutoring platform for government exams and university entrance preparation.',
    'footer.quickLinks': 'Quick Links',
    'footer.aboutUs': 'About Us',
    'footer.careers': 'Careers',
    'footer.blog': 'Blog',
    'footer.contact': 'Contact',
    'footer.support': 'Support',
    'footer.helpCenter': 'Help Center',
    'footer.terms': 'Terms of Service',
    'footer.privacy': 'Privacy Policy',
    'footer.accessibility': 'Accessibility',
    'footer.newsletter': 'Newsletter',
    'footer.newsletterDescription': 'Stay updated with our latest AI courses and features',
    'footer.emailPlaceholder': 'Your email',
    'footer.copyright': '© 2025 Nexus Learn. All rights reserved.',
  },
  th: {
    // Navbar
    'nav.courses': 'คอร์สเรียน',
    'nav.categories': 'หมวดหมู่',
    'nav.about': 'เกี่ยวกับเรา',
    'nav.contact': 'ติดต่อเรา',
    'nav.signIn': 'เข้าสู่ระบบ',
    'nav.getStarted': 'เริ่มต้นเรียน',
    
    // Hero
    'hero.badge': '🤖 แพลตฟอร์มติวด้วย AI',
    'hero.title': 'สอบติดแน่นอนกับ',
    'hero.titleHighlight': 'ระบบติว AI อัจฉริยะ',
    'hero.description': 'ระบบติวอัจฉริยะด้วย AI สำหรับสอบ กพ และเข้ามหาวิทยาลัย เรียนรู้อย่างชอบฉลาดด้วย AI ที่ปรับตามความสามารถและวิเคราะห์จุดอ่อนของคุณ',
    'hero.searchPlaceholder': 'คุณต้องการเรียนอะไร?',
    'hero.searchButton': 'ค้นหาคอร์ส',
    'hero.stats.students': 'นักเรียนที่ใช้งาน',
    'hero.stats.courses': 'คอร์ส AI',
    'hero.stats.instructors': 'AI Tutors',
    'hero.completion': 'วิเคราะห์โดย AI',
    'hero.successRate': 'เรียนได้ 24/7',
    
    // Courses
    'courses.title': 'คอร์สติวด้วย AI',
    'courses.description': 'สำรวจคอร์สติว AI ที่ปรับการเรียนให้เหมาะกับคุณ',
    'courses.viewAll': 'ดูคอร์สทั้งหมด',
    'courses.enrollNow': 'เริ่มเรียนเลย',
    'courses.by': 'โดย',
    'courses.level.beginner': 'เริ่มต้น',
    'courses.level.intermediate': 'ปานกลาง',
    'courses.level.advanced': 'ขั้นสูง',
    
    // Course Details
    'course.1.title': 'ติวสอบ กพ ภาค ก. ด้วย AI แบบเข้มข้น',
    'course.1.instructor': 'AI Tutor Pro',
    'course.2.title': 'ติวสอบ กพ ภาค ข. พิชิตข้อสอบด้วย AI',
    'course.2.instructor': 'AI Tutor Pro',
    'course.3.title': 'คณิตศาสตร์ ม.ปลาย - AI ปรับระดับ',
    'course.3.instructor': 'AI Math Master',
    'course.4.title': 'วิทยาศาสตร์ ม.ปลาย - เรียนกับ AI',
    'course.4.instructor': 'AI Science Expert',
    
    // Categories
    'categories.title': 'เรียกดูตามหมวดหมู่',
    'categories.description': 'ค้นหาคอร์ส AI ที่เหมาะกับคุณ',
    'category.civil': 'สอบราชการ กพ',
    'category.math': 'คณิตศาสตร์',
    'category.science': 'วิทยาศาสตร์',
    'category.thai': 'ภาษาไทย',
    'category.english': 'ภาษาอังกฤษ',
    'category.social': 'สังคมศึกษา',
    'category.coursesCount': 'คอร์ส AI',
    
    // Testimonials
    'testimonials.title': 'เรื่องราวความสำเร็จ',
    'testimonials.description': 'นักเรียนที่ประสบความสำเร็จด้วยระบบติว AI',
    'testimonial.1.name': 'คุณ สมหญิง ใจดี',
    'testimonial.1.role': 'นักศึกษาจุฬาลงกรณ์มหาวิทยาลัย',
    'testimonial.1.content': 'AI วิเคราะห์จุดอ่อนของฉันและสร้างแผนการเรียนเฉพาะตัว ฉันฝึกได้ 24/7 และสอบติดมหาลัยในฝัน!',
    'testimonial.2.name': 'คุณ ณัฐพล รักเรียน',
    'testimonial.2.role': 'ข้าราชการ กรมสรรพากร',
    'testimonial.2.content': 'ระบบ AI สำหรับสอบ กพ ยอดเยี่ยมมาก ปรับตามความเร็วในการเรียนและเน้นหัวข้อที่ผมยังไม่เข้าใจ สอบผ่านด้วยคะแนนสูง!',
    'testimonial.3.name': 'คุณ วรรณา เรียนดี',
    'testimonial.3.role': 'นักเรียน ม.6',
    'testimonial.3.content': 'เรียนกับ AI สุดยอดมาก! เรียนได้ทุกเวลา ได้คำตอบทันที และระบบรู้ว่าฉันต้องพัฒนาตรงไหน',
    
    // CTA
    'cta.title': 'พร้อมเรียนกับ AI หรือยัง?',
    'cta.description': 'เข้าร่วมกับนักเรียนหลายพันคนที่เรียนอย่างชาญฉลาดด้วยระบบติว AI',
    'cta.browseCourses': 'เรียกดูคอร์ส AI',
    'cta.becomeInstructor': 'ร่วมงานกับเรา',
    
    // Footer
    'footer.description': 'แพลตฟอร์มติวด้วย AI แห่งแรกของไทย สำหรับสอบราชการและสอบเข้ามหาวิทยาลัย',
    'footer.quickLinks': 'ลิงก์ด่วน',
    'footer.aboutUs': 'เกี่ยวกับเรา',
    'footer.careers': 'ร่วมงานกับเรา',
    'footer.blog': 'บล็อก',
    'footer.contact': 'ติดต่อเรา',
    'footer.support': 'ฝ่ายสนับสนุน',
    'footer.helpCenter': 'ศูนย์ช่วยเหลือ',
    'footer.terms': 'ข้อกำหนดการให้บริการ',
    'footer.privacy': 'นโยบายความเป็นส่วนตัว',
    'footer.accessibility': 'การเข้าถึง',
    'footer.newsletter': 'จดหมายข่าว',
    'footer.newsletterDescription': 'รับข้อมูลอัพเดทคอร์ส AI และฟีเจอร์ใหม่ๆ',
    'footer.emailPlaceholder': 'อีเมลของคุณ',
    'footer.copyright': '© 2025 Nexus Learn สงวนลิขสิทธิ์',
  },
};

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [language, setLanguage] = useState<Language>('th');

  const t = (key: string): string => {
    return translations[language][key as keyof typeof translations['en']] || key;
  };

  const toggle = () => {
    setLanguage(language === 'th' ? 'en' : 'th');
  };

  return (
    <LanguageContext.Provider value={{ language, setLanguage, t, toggle }}>
      {children}
    </LanguageContext.Provider>
  );
}

export function useLanguage() {
  const context = useContext(LanguageContext);
  if (context === undefined) {
    throw new Error('useLanguage must be used within a LanguageProvider');
  }
  return context;
}

