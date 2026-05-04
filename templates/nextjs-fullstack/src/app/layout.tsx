import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'PROJECT_NAME - Next.js Application',
  description: 'A modern Next.js full-stack web application',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <div className="min-h-screen bg-background">
          <header className="border-b">
            <div className="container mx-auto px-4 py-4">
              <nav className="flex items-center justify-between">
                <div className="text-xl font-bold">PROJECT_NAME</div>
                <div className="flex space-x-4">
                  <a href="/" className="hover:text-primary">Home</a>
                  <a href="/about" className="hover:text-primary">About</a>
                  <a href="/api/health" className="hover:text-primary">API Health</a>
                </div>
              </nav>
            </div>
          </header>
          <main className="container mx-auto px-4 py-8">
            {children}
          </main>
          <footer className="border-t mt-8 py-6">
            <div className="container mx-auto px-4 text-center text-muted-foreground">
              <p>© CURRENT_YEAR PROJECT_NAME. Built with Next.js and OpenClaw Scaffolding Engine.</p>
            </div>
          </footer>
        </div>
      </body>
    </html>
  )
}