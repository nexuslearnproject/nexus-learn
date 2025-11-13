'use client';

import { Star } from 'lucide-react';
import { Card, CardContent, Avatar, AvatarFallback } from '@/components/ui';

interface TestimonialCardProps {
  name: string;
  role: string;
  content: string;
  rating: number;
  initials: string;
}

export function TestimonialCard({ name, role, content, rating, initials }: TestimonialCardProps) {
  return (
    <Card className="h-full">
      <CardContent className="p-6 space-y-4">
        <div className="flex gap-1">
          {[...Array(5)].map((_, i) => (
            <Star
              key={i}
              className={`h-4 w-4 ${
                i < rating ? 'fill-yellow-400 text-yellow-400' : 'text-gray-300'
              }`}
            />
          ))}
        </div>
        <p className="text-gray-600 italic">&ldquo;{content}&rdquo;</p>
        <div className="flex items-center gap-3 pt-2">
          <Avatar>
            <AvatarFallback className="bg-blue-600 text-white">
              {initials}
            </AvatarFallback>
          </Avatar>
          <div>
            <div className="font-semibold">{name}</div>
            <div className="text-sm text-gray-600">{role}</div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

