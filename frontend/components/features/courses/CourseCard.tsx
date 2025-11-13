'use client';

import Link from 'next/link';
import { Card, CardContent, CardFooter, Badge, Button } from '@/components/ui';
import { Star, Users, Clock } from 'lucide-react';
import { useLanguage } from '@/contexts/LanguageContext';

interface CourseCardProps {
  id: number;
  title: string;
  instructor: string;
  image: string;
  price: string;
  rating: number;
  students: number;
  duration: string;
  level: string;
  category: string;
}

export function CourseCard({
  id,
  title,
  instructor,
  image,
  price,
  rating,
  students,
  duration,
  level,
  category,
}: CourseCardProps) {
  const { t, language } = useLanguage();

  // Check if this is the Math course (id: 3)
  const isMathCourse = id === 3;
  const buttonText = isMathCourse 
    ? (language === 'th' ? 'ทดลองเรียนฟรี' : 'Free Trial')
    : t('courses.enrollNow');

  return (
    <Card className="overflow-hidden hover:shadow-lg transition-shadow group">
      <Link href={`/courses/${id}`}>
        <div className="relative aspect-video overflow-hidden cursor-pointer">
          <img 
            src={image} 
            alt={title}
            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
          />
          <Badge className="absolute top-3 right-3 bg-blue-600">
            {category}
          </Badge>
        </div>
      </Link>
      <CardContent className="p-5 space-y-3">
        <div className="flex items-center justify-between">
          <Badge variant="outline">{level}</Badge>
          <div className="flex items-center gap-1">
            <Star className="h-4 w-4 fill-yellow-400 text-yellow-400" />
            <span className="text-sm">{rating}</span>
          </div>
        </div>
        <Link href={`/courses/${id}`}>
          <h3 className="line-clamp-2 min-h-[3rem] font-semibold hover:text-blue-600 transition-colors cursor-pointer">{title}</h3>
        </Link>
        <p className="text-sm text-gray-600">{t('courses.by')} {instructor}</p>
        <div className="flex items-center gap-4 text-sm text-gray-600">
          <div className="flex items-center gap-1">
            <Clock className="h-4 w-4" />
            <span>{duration}</span>
          </div>
          <div className="flex items-center gap-1">
            <Users className="h-4 w-4" />
            <span>{students.toLocaleString()}</span>
          </div>
        </div>
      </CardContent>
      <CardFooter className="p-5 pt-0 flex items-center justify-between">
        <div className="text-2xl text-blue-600 font-bold">{price}</div>
        <Link href={`/courses/${id}`}>
          <Button>{buttonText}</Button>
        </Link>
      </CardFooter>
    </Card>
  );
}

