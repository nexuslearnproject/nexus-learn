'use client';

import { useState } from 'react';
import {
  Button,
  Input,
  Checkbox,
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  Label,
} from '@/components/ui';
import { useLanguage } from '@/contexts/LanguageContext';

interface AuthModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function AuthModal({ open, onOpenChange }: AuthModalProps) {
  const { t } = useLanguage();
  const [isSignUp, setIsSignUp] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Handle form submission here
    console.log('Form submitted', { email, password, isSignUp });
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[425px] p-8 max-h-[90vh] overflow-y-auto">
        <DialogHeader className="space-y-2 pb-4">
          <DialogTitle className="text-2xl font-bold text-left text-gray-900">
            {isSignUp ? t('auth.signUp') : t('auth.signIn')}
          </DialogTitle>
          <DialogDescription className="text-left text-sm text-gray-700 leading-relaxed">
            {isSignUp ? t('auth.signUpDescription') : t('auth.signInDescription')}
          </DialogDescription>
        </DialogHeader>
        
        <form onSubmit={handleSubmit} className="space-y-5">
          {/* Social Login Buttons */}
          <div className="space-y-3">
            <Button
              type="button"
              variant="outline"
              className="w-full h-12 justify-start gap-3 border border-gray-300 bg-white hover:bg-gray-50 text-gray-900 font-normal text-sm shadow-sm"
              onClick={() => console.log('Google login')}
            >
              <svg className="h-5 w-5 shrink-0" viewBox="0 0 24 24">
                <path
                  fill="#4285F4"
                  d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                />
                <path
                  fill="#34A853"
                  d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                />
                <path
                  fill="#FBBC05"
                  d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                />
                <path
                  fill="#EA4335"
                  d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                />
              </svg>
              <span className="flex-1 text-left">{t('auth.continueWithGoogle')}</span>
            </Button>
            
            <Button
              type="button"
              className="w-full h-12 justify-start gap-3 bg-[#1877F2] hover:bg-[#166FE5] text-white font-normal text-sm shadow-sm"
              onClick={() => console.log('Facebook login')}
            >
              <svg className="h-5 w-5 shrink-0" viewBox="0 0 24 24" fill="white">
                <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
              </svg>
              <span className="flex-1 text-left">{t('auth.continueWithFacebook')}</span>
            </Button>
          </div>

          {/* Divider */}
          <div className="relative my-6">
            <div className="absolute inset-0 flex items-center">
              <span className="w-full border-t border-gray-200" />
            </div>
            <div className="relative flex justify-center text-xs text-gray-500">
              <span className="bg-white px-3">
                {t('auth.orContinueWith')}
              </span>
            </div>
          </div>

          {/* Email Input */}
          <div className="space-y-2">
            <Label htmlFor="email" className="text-sm font-medium text-gray-900">
              {t('auth.email')}
            </Label>
            <Input
              id="email"
              type="email"
              placeholder={t('auth.emailPlaceholder')}
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              className="h-12 bg-gray-100 border-gray-300 focus:bg-white focus:border-gray-400 text-gray-900 placeholder:text-gray-400"
            />
          </div>

          {/* Password Input */}
          <div className="space-y-2">
            <Label htmlFor="password" className="text-sm font-medium text-gray-900">
              {t('auth.password')}
            </Label>
            <Input
              id="password"
              type="password"
              placeholder={t('auth.passwordPlaceholder')}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="h-12 bg-gray-100 border-gray-300 focus:bg-white focus:border-gray-400 text-gray-900 placeholder:text-gray-400"
            />
          </div>

          {/* Confirm Password (only for sign up) */}
          {isSignUp && (
            <div className="space-y-2">
              <Label htmlFor="confirmPassword" className="text-sm font-medium text-gray-900">
                {t('auth.confirmPassword')}
              </Label>
              <Input
                id="confirmPassword"
                type="password"
                placeholder={t('auth.confirmPasswordPlaceholder')}
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                required
                className="h-12 bg-gray-100 border-gray-300 focus:bg-white focus:border-gray-400 text-gray-900 placeholder:text-gray-400"
              />
            </div>
          )}

          {/* Remember Me & Forgot Password */}
          {!isSignUp && (
            <div className="flex items-center justify-between pt-1">
              <div className="flex items-center space-x-2.5">
                <Checkbox
                  id="remember"
                  checked={rememberMe}
                  onCheckedChange={(checked) => setRememberMe(checked === true)}
                  className="h-4 w-4 border-gray-400 data-[state=checked]:bg-gray-900 data-[state=checked]:border-gray-900"
                />
                <Label
                  htmlFor="remember"
                  className="text-sm font-normal cursor-pointer text-gray-900 leading-none"
                >
                  {t('auth.rememberMe')}
                </Label>
              </div>
              <button
                type="button"
                className="text-sm text-blue-600 hover:text-blue-700 hover:underline font-normal"
                onClick={() => console.log('Forgot password')}
              >
                {t('auth.forgotPassword')}
              </button>
            </div>
          )}

          {/* Submit Button */}
          <Button 
            type="submit" 
            className="w-full h-12 text-base font-semibold bg-gray-900 hover:bg-black text-white shadow-sm mt-2"
          >
            {isSignUp ? t('auth.signUp') : t('auth.signIn')}
          </Button>

          {/* Sign Up / Sign In Toggle */}
          <div className="text-center text-sm pt-3 text-gray-700">
            {isSignUp ? (
              <>
                <span>{t('auth.haveAccount')} </span>
                <button
                  type="button"
                  onClick={() => setIsSignUp(false)}
                  className="text-blue-600 hover:text-blue-700 hover:underline font-normal"
                >
                  {t('auth.signIn')}
                </button>
              </>
            ) : (
              <>
                <span>{t('auth.noAccount')} </span>
                <button
                  type="button"
                  onClick={() => setIsSignUp(true)}
                  className="text-blue-600 hover:text-blue-700 hover:underline font-normal"
                >
                  {t('auth.signUp')}
                </button>
              </>
            )}
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
