import type { Metadata } from 'next'
import '@/styles/globals.css'

export const metadata: Metadata = {
  title: 'Nexus Learn - Modern Learning Platform',
  description: 'Learn, Build, and Grow with Nexus Learn. A modern learning platform built with Next.js, Django, and AWS.',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}

