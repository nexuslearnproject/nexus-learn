'use client';

import { useState } from 'react';
import Link from 'next/link';
import { Menu, Search } from 'lucide-react';
import { Button, Sheet, SheetContent, SheetTrigger, SheetTitle, SheetDescription } from '@/components/ui';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui';
import { useLanguage } from '@/contexts/LanguageContext';
import { NexusLearnLogo } from './NexusLearnLogo';
import { AuthModal } from '@/components/features/auth';

export function Navbar() {
  const [isOpen, setIsOpen] = useState(false);
  const [authModalOpen, setAuthModalOpen] = useState(false);
  const { language, setLanguage, t } = useLanguage();

  const navLinks = [
    { name: t('nav.courses'), href: '/courses' },
    { name: t('nav.categories'), href: '/#categories' },
    { name: t('nav.about'), href: '/about' },
    { name: t('nav.contact'), href: '/#contact' },
  ];

  return (
    <>
      <nav className="sticky top-0 z-50 w-full border-b bg-white/95 backdrop-blur supports-[backdrop-filter]:bg-white/80">
        <div className="container mx-auto px-4">
          <div className="flex h-16 items-center justify-between">
            {/* Logo */}
            <Link href="/" className="flex items-center gap-2">
              <NexusLearnLogo />
            </Link>

            {/* Desktop Navigation */}
            <div className="hidden md:flex items-center gap-8">
              {navLinks.map((link) => (
                <Link
                  key={link.name}
                  href={link.href}
                  className="text-gray-600 hover:text-gray-900 transition-colors"
                >
                  {link.name}
                </Link>
              ))}
            </div>

            {/* Desktop Actions */}
            <div className="hidden md:flex items-center gap-4">
              <Button variant="ghost" size="icon">
                <Search className="h-5 w-5" />
              </Button>
              
              {/* Quick Access to Dashboard (Demo) */}
              <Link href="/dashboard">
                <Button 
                  variant="ghost" 
                  size="sm"
                  className="text-xs bg-yellow-100 text-yellow-800 hover:bg-yellow-200 hover:text-yellow-900"
                >
                  🚀 Dashboard Demo
                </Button>
              </Link>
              
              {/* Language Switcher */}
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <button className="inline-flex items-center justify-center h-10 px-3 gap-2 rounded-md hover:bg-gray-100 transition-colors border border-gray-200">
                    <span className="text-xl">{language === 'en' ? '🇺🇸' : '🇹🇭'}</span>
                  </button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end">
                  <DropdownMenuItem 
                    onClick={() => setLanguage('en')}
                    className={language === 'en' ? 'bg-blue-50' : ''}
                  >
                    <span className="text-xl mr-2">🇺🇸</span>
                    English
                  </DropdownMenuItem>
                  <DropdownMenuItem 
                    onClick={() => setLanguage('th')}
                    className={language === 'th' ? 'bg-blue-50' : ''}
                  >
                    <span className="text-xl mr-2">🇹🇭</span>
                    ไทย
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
              
              <Button variant="ghost" onClick={() => setAuthModalOpen(true)}>
                {t('nav.signIn')}
              </Button>
              <Button onClick={() => setAuthModalOpen(true)}>
                {t('nav.getStarted')}
              </Button>
            </div>

            {/* Mobile Menu */}
            <Sheet open={isOpen} onOpenChange={setIsOpen}>
              <SheetTrigger asChild className="md:hidden">
                <button className="inline-flex items-center justify-center h-10 w-10 rounded-md hover:bg-gray-100 transition-colors md:hidden">
                  <Menu className="h-6 w-6" />
                </button>
              </SheetTrigger>
              <SheetContent side="right" className="w-[300px]">
                <SheetTitle className="sr-only">Navigation Menu</SheetTitle>
                <SheetDescription className="sr-only">
                  Main navigation and language settings
                </SheetDescription>
                <div className="flex flex-col gap-2 mt-6">
                  {/* Navigation Links */}
                  <div className="space-y-1">
                    {navLinks.map((link) => (
                      <Link
                        key={link.name}
                        href={link.href}
                        onClick={() => setIsOpen(false)}
                        className="block px-3 py-2.5 text-base text-gray-700 hover:text-gray-900 hover:bg-gray-50 rounded-md transition-colors"
                      >
                        {link.name}
                      </Link>
                    ))}
                  </div>
                  
                  {/* Language Switcher */}
                  <div className="pt-5 pb-4 px-3 border-t mt-4">
                    <div className="text-sm text-gray-500 mb-3">Language / ภาษา</div>
                    <div className="grid grid-cols-2 gap-2">
                      <Button 
                        variant={language === 'en' ? 'default' : 'outline'}
                        size="sm"
                        className="gap-2 h-10"
                        onClick={() => setLanguage('en')}
                      >
                        <span className="text-lg">🇺🇸</span>
                        <span className="text-sm">English</span>
                      </Button>
                      <Button 
                        variant={language === 'th' ? 'default' : 'outline'}
                        size="sm"
                        className="gap-2 h-10"
                        onClick={() => setLanguage('th')}
                      >
                        <span className="text-lg">🇹🇭</span>
                        <span className="text-sm">ไทย</span>
                      </Button>
                    </div>
                  </div>
                  
                  {/* Auth Buttons */}
                  <div className="flex flex-col gap-2 px-3 pt-4 pb-3 border-t">
                    <Link href="/dashboard" onClick={() => setIsOpen(false)}>
                      <Button 
                        variant="secondary"
                        className="w-full h-11"
                      >
                        🚀 Dashboard Demo
                      </Button>
                    </Link>
                    <Button 
                      variant="outline" 
                      className="w-full h-11"
                      onClick={() => {
                        setIsOpen(false);
                        setAuthModalOpen(true);
                      }}
                    >
                      {t('nav.signIn')}
                    </Button>
                    <Button 
                      className="w-full h-11"
                      onClick={() => {
                        setIsOpen(false);
                        setAuthModalOpen(true);
                      }}
                    >
                      {t('nav.getStarted')}
                    </Button>
                  </div>
                </div>
              </SheetContent>
            </Sheet>
          </div>
        </div>
      </nav>

      <AuthModal open={authModalOpen} onOpenChange={setAuthModalOpen} />
    </>
  );
}

