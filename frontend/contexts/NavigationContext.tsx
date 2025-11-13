'use client';

import { createContext, useContext, useState, ReactNode } from 'react';

type Page = 'home' | 'dashboard' | 'all-courses' | 'course-detail' | 'learning-path' | 'lesson-chat';

interface CourseContext {
  id?: number;
  name?: string;
  nameEn?: string;
}

interface LessonContext {
  id?: number;
  title?: string;
  titleEn?: string;
}

interface NavigationContextType {
  currentPage: Page;
  setCurrentPage: (page: Page) => void;
  courseContext?: CourseContext;
  setCourseContext: (context?: CourseContext) => void;
  lessonContext?: LessonContext;
  setLessonContext: (context?: LessonContext) => void;
  pageParams?: { id?: number };
  navigateTo: (page: Page, params?: { id?: number }) => void;
}

const NavigationContext = createContext<NavigationContextType | undefined>(undefined);

export function NavigationProvider({ children }: { children: ReactNode }) {
  const [currentPage, setCurrentPage] = useState<Page>('home');
  const [courseContext, setCourseContext] = useState<CourseContext | undefined>();
  const [lessonContext, setLessonContext] = useState<LessonContext | undefined>();
  const [pageParams, setPageParams] = useState<{ id?: number } | undefined>();

  const navigateTo = (page: Page, params?: { id?: number }) => {
    setCurrentPage(page);
    setPageParams(params);
  };

  return (
    <NavigationContext.Provider value={{
      currentPage,
      setCurrentPage,
      courseContext,
      setCourseContext,
      lessonContext,
      setLessonContext,
      pageParams,
      navigateTo,
    }}>
      {children}
    </NavigationContext.Provider>
  );
}

export function useNavigation() {
  const context = useContext(NavigationContext);
  if (context === undefined) {
    throw new Error('useNavigation must be used within a NavigationProvider');
  }
  return context;
}

