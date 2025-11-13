export interface Course {
  id: number;
  title: string;
  titleTh?: string;
  titleEn?: string;
  instructor: string;
  image: string;
  price: string;
  rating: number;
  students: number;
  duration: string;
  level: string;
  category: string;
  description?: string;
  lessons?: number;
  language?: string;
}

export interface Category {
  title: string;
  courses: number;
  icon: any;
  color: string;
}

export interface Testimonial {
  name: string;
  role: string;
  content: string;
  rating: number;
  initials: string;
}

