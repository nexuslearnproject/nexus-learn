'use client';

import Link from 'next/link';
import { LanguageProvider, useLanguage } from '@/contexts/LanguageContext';
import { Navbar } from '@/components/layout';
import { Button, Card, CardContent } from '@/components/ui';
import { 
  Target,
  Users,
  Award,
  TrendingUp,
  BookOpen,
  Heart,
  Lightbulb,
  Shield,
} from 'lucide-react';

function AboutContent() {
  const { t } = useLanguage();

  const stats = [
    { label: 'นักเรียน', value: '50,000+', icon: Users },
    { label: 'คอร์สเรียน', value: '500+', icon: BookOpen },
    { label: 'อาจารย์ผู้สอน', value: '150+', icon: Award },
    { label: 'ความพึงพอใจ', value: '98%', icon: Heart },
  ];

  const values = [
    {
      icon: Target,
      title: 'มุ่งเน้นผลลัพธ์',
      description: 'เราออกแบบคอร์สเพื่อให้นักเรียนบรรลุเป้าหมายการเรียนรู้ที่ชัดเจน',
    },
    {
      icon: Lightbulb,
      title: 'นวัตกรรม',
      description: 'ใช้เทคโนโลยีและวิธีการสอนที่ทันสมัยเพื่อประสบการณ์การเรียนรู้ที่ดีที่สุด',
    },
    {
      icon: Shield,
      title: 'คุณภาพ',
      description: 'เนื้อหาทุกคอร์สได้รับการตรวจสอบโดยผู้เชี่ยวชาญเพื่อมาตรฐานสูงสุด',
    },
    {
      icon: Users,
      title: 'ชุมชน',
      description: 'สร้างสภาพแวดล้อมการเรียนรู้ที่สนับสนุนและส่งเสริมซึ่งกันและกัน',
    },
  ];

  const team = [
    {
      name: 'ดร.สมชาย วงศ์ใหญ่',
      position: 'ผู้ก่อตั้งและ CEO',
      description: 'อดีตอาจารย์จุฬาฯ ด้วยประสบการณ์ด้านการศึกษากว่า 15 ปี',
    },
    {
      name: 'อ.สุดารัตน์ ศรีสุข',
      position: 'Chief Academic Officer',
      description: 'ผู้เชี่ยวชาญด้านหลักสูตรและการพัฒนาเนื้อหาการเรียนรู้',
    },
    {
      name: 'คุณธนพล วีระชัย',
      position: 'Head of Technology',
      description: 'วิศวกรซอฟต์แวร์ที่มีประสบการณ์กว่า 10 ปี',
    },
    {
      name: 'คุณนิภา แสงจันทร์',
      position: 'Head of Student Success',
      description: 'ทีมงานที่มุ่งมั่นในการช่วยเหลือนักเรียนให้ประสบความสำเร็จ',
    },
  ];

  return (
    <div className="min-h-screen bg-white">
      <Navbar />
      
      {/* Hero Section */}
      <section className="bg-gradient-to-r from-blue-600 to-purple-600 text-white py-20">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl mx-auto text-center">
            <h1 className="text-4xl md:text-5xl font-bold mb-6">
              เกี่ยวกับ Nexus Learn
            </h1>
            <p className="text-xl text-blue-100 leading-relaxed">
              เราคือแพลตฟอร์มการเรียนรู้ออนไลน์ที่มุ่งมั่นในการสร้างอนาคตที่ดีกว่า
              ผ่านการศึกษาที่มีคุณภาพและเข้าถึงได้สำหรับทุกคน
            </p>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-16 bg-gray-50">
        <div className="container mx-auto px-4">
          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-8">
            {stats.map((stat, index) => {
              const Icon = stat.icon;
              return (
                <Card key={index}>
                  <CardContent className="p-6 text-center">
                    <div className="inline-flex items-center justify-center h-16 w-16 rounded-full bg-blue-100 text-blue-600 mb-4">
                      <Icon className="h-8 w-8" />
                    </div>
                    <div className="text-4xl font-bold mb-2">{stat.value}</div>
                    <div className="text-gray-600">{stat.label}</div>
                  </CardContent>
                </Card>
              );
            })}
          </div>
        </div>
      </section>

      {/* Mission Section */}
      <section className="py-16">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto">
            <div className="text-center mb-12">
              <h2 className="text-3xl md:text-4xl font-bold mb-4">
                พันธกิจของเรา
              </h2>
              <p className="text-xl text-gray-600">
                สร้างประสบการณ์การเรียนรู้ที่เปลี่ยนแปลงชีวิตผู้คน
              </p>
            </div>
            
            <Card>
              <CardContent className="p-8">
                <p className="text-lg text-gray-700 leading-relaxed mb-6">
                  Nexus Learn ก่อตั้งขึ้นด้วยความเชื่อมั่นว่าการศึกษาคุณภาพสูงควรเข้าถึงได้สำหรับทุกคน
                  ไม่ว่าคุณจะอยู่ที่ไหนหรือมีพื้นฐานการศึกษาอย่างไร เรามุ่งมั่นที่จะเป็นสะพานเชื่อมระหว่าง
                  ความรู้และความสำเร็จของผู้เรียนทุกคน
                </p>
                <p className="text-lg text-gray-700 leading-relaxed">
                  ด้วยทีมงานผู้เชี่ยวชาญและเทคโนโลยีที่ทันสมัย เรานำเสนอคอร์สเรียนที่ออกแบบมาอย่างพิถีพิถัน
                  เพื่อตอบสนองความต้องการของผู้เรียนในยุคดิจิทัล และเตรียมพร้อมสำหรับอนาคตที่เปลี่ยนแปลงไป
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Values Section */}
      <section className="py-16 bg-gray-50">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl font-bold mb-4">
              คุณค่าหลักของเรา
            </h2>
            <p className="text-xl text-gray-600">
              หลักการที่ขับเคลื่อนทุกสิ่งที่เราทำ
            </p>
          </div>
          
          <div className="grid md:grid-cols-2 gap-6 max-w-5xl mx-auto">
            {values.map((value, index) => {
              const Icon = value.icon;
              return (
                <Card key={index}>
                  <CardContent className="p-6">
                    <div className="flex items-start gap-4">
                      <div className="flex-shrink-0 h-12 w-12 rounded-lg bg-blue-600 text-white flex items-center justify-center">
                        <Icon className="h-6 w-6" />
                      </div>
                      <div>
                        <h3 className="text-xl font-bold mb-2">{value.title}</h3>
                        <p className="text-gray-600">{value.description}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              );
            })}
          </div>
        </div>
      </section>

      {/* Team Section */}
      <section className="py-16">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl font-bold mb-4">
              ทีมงานของเรา
            </h2>
            <p className="text-xl text-gray-600">
              ผู้นำที่ขับเคลื่อน Nexus Learn
            </p>
          </div>
          
          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6 max-w-6xl mx-auto">
            {team.map((member, index) => (
              <Card key={index}>
                <CardContent className="p-6 text-center">
                  <div className="h-24 w-24 rounded-full bg-gradient-to-br from-blue-600 to-purple-600 text-white text-3xl font-bold flex items-center justify-center mx-auto mb-4">
                    {member.name.charAt(member.name.indexOf('.') + 1)}
                  </div>
                  <h3 className="font-bold text-lg mb-1">{member.name}</h3>
                  <p className="text-blue-600 text-sm font-medium mb-3">
                    {member.position}
                  </p>
                  <p className="text-gray-600 text-sm">
                    {member.description}
                  </p>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 bg-gradient-to-r from-blue-600 to-purple-600 text-white">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl md:text-4xl font-bold mb-4">
            พร้อมที่จะเริ่มต้นการเรียนรู้แล้วหรือยัง?
          </h2>
          <p className="text-xl text-blue-100 mb-8 max-w-2xl mx-auto">
            เข้าร่วมกับนักเรียนหลายหมื่นคนที่เปลี่ยนแปลงชีวิตของพวกเขาผ่านการเรียนรู้
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link href="/courses">
              <Button size="lg" variant="secondary">
                เรียกดูคอร์ส
              </Button>
            </Link>
            <Link href="/#contact">
              <Button 
                size="lg" 
                variant="outline" 
                className="bg-transparent text-white border-white hover:bg-white hover:text-blue-600"
              >
                ติดต่อเรา
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-gray-300 py-12">
        <div className="container mx-auto px-4 text-center">
          <p className="text-sm">© 2024 Nexus Learn. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
}

export default function AboutPage() {
  return (
    <LanguageProvider>
      <AboutContent />
    </LanguageProvider>
  );
}

