import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import App from '../src/App'

// Mock the API module
vi.mock('../src/services/api', () => ({
  api: {
    get: vi.fn().mockResolvedValue({
      status: 'healthy',
      timestamp: '2024-01-01T00:00:00.000Z',
      service: 'PROJECT_NAME-server',
      version: '0.1.0',
      uptime: '100',
      environment: 'test',
    }),
  },
}))

describe('App', () => {
  it('renders the main heading', () => {
    render(<App />)
    const heading = screen.getByText(/Welcome to PROJECT_NAME/i)
    expect(heading).toBeInTheDocument()
  })

  it('renders the subtitle', () => {
    render(<App />)
    const subtitle = screen.getByText(/Express.js \+ React Client-Server Application/i)
    expect(subtitle).toBeInTheDocument()
  })

  it('renders feature cards', () => {
    render(<App />)
    expect(screen.getByText('🚀 Frontend')).toBeInTheDocument()
    expect(screen.getByText('🔧 Backend')).toBeInTheDocument()
    expect(screen.getByText('⚡ Development')).toBeInTheDocument()
  })

  it('renders system health section', () => {
    render(<App />)
    expect(screen.getByText('📊 System Health')).toBeInTheDocument()
  })

  it('renders getting started section', () => {
    render(<App />)
    expect(screen.getByText('📖 Getting Started')).toBeInTheDocument()
  })
})