'use client';

import { LucideIcon } from 'lucide-react';
import { Card, CardContent } from '@/components/ui';
import { useLanguage } from '@/contexts/LanguageContext';

interface CategoryCardProps {
  title: string;
  courses: number;
  icon: LucideIcon;
  color: string;
}

export function CategoryCard({ title, courses, icon: Icon, color }: CategoryCardProps) {
  const { t } = useLanguage();
  
  return (
    <Card className="hover:shadow-lg transition-all cursor-pointer group border-2 hover:border-blue-500">
      <CardContent className="p-6 text-center space-y-4">
        <div className={`mx-auto h-16 w-16 rounded-full ${color} flex items-center justify-center group-hover:scale-110 transition-transform`}>
          <Icon className="h-8 w-8 text-white" />
        </div>
        <div>
          <h3 className="mb-1 font-semibold">{title}</h3>
          <p className="text-sm text-gray-600">{courses} {t('category.coursesCount')}</p>
        </div>
      </CardContent>
    </Card>
  );
}

