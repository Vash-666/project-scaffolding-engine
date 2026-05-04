import { useState, useEffect } from 'react'
import { api } from './services/api'
import './App.css'

interface HealthStatus {
  status: string
  timestamp: string
  service: string
  version: string
  uptime: string
  environment: string
}

function App() {
  const [health, setHealth] = useState<HealthStatus | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchHealth()
  }, [])

  const fetchHealth = async () => {
    try {
      setLoading(true)
      const data = await api.get<HealthStatus>('/health')
      setHealth(data)
      setError(null)
    } catch (err) {
      setError('Failed to fetch health status')
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="app">
      <header className="header">
        <h1>Welcome to <span className="highlight">PROJECT_NAME</span></h1>
        <p className="subtitle">Express.js + React Client-Server Application</p>
      </header>

      <main className="main">
        <div className="cards">
          <div className="card">
            <h2>🚀 Frontend</h2>
            <p>React 18+ with TypeScript and Vite</p>
            <ul>
              <li>Modern React features</li>
              <li>Type-safe development</li>
              <li>Fast development server</li>
              <li>Optimized production builds</li>
            </ul>
          </div>

          <div className="card">
            <h2>🔧 Backend</h2>
            <p>Express.js with TypeScript</p>
            <ul>
              <li>RESTful API design</li>
              <li>Security middleware (Helmet, CORS)</li>
              <li>Logging and error handling</li>
              <li>Health check endpoints</li>
            </ul>
          </div>

          <div className="card">
            <h2>⚡ Development</h2>
            <p>Monorepo with npm workspaces</p>
            <ul>
              <li>Concurrent development</li>
              <li>Shared tooling</li>
              <li>Unified testing</li>
              <li>Consistent code style</li>
            </ul>
          </div>
        </div>

        <div className="health-section">
          <h2>📊 System Health</h2>
          {loading ? (
            <p>Loading health status...</p>
          ) : error ? (
            <p className="error">{error}</p>
          ) : health ? (
            <div className="health-card">
              <div className="health-status">
                <span className={`status-indicator ${health.status}`}>
                  {health.status.toUpperCase()}
                </span>
                <span className="timestamp">
                  {new Date(health.timestamp).toLocaleString()}
                </span>
              </div>
              <div className="health-details">
                <p><strong>Service:</strong> {health.service}</p>
                <p><strong>Version:</strong> {health.version}</p>
                <p><strong>Uptime:</strong> {Math.floor(parseFloat(health.uptime))} seconds</p>
                <p><strong>Environment:</strong> {health.environment}</p>
              </div>
              <button onClick={fetchHealth} className="refresh-btn">
                Refresh Health
              </button>
            </div>
          ) : null}
        </div>

        <div className="instructions">
          <h2>📖 Getting Started</h2>
          <div className="code-block">
            <code># Install dependencies</code>
            <code>npm install</code>
            <br />
            <code># Start development servers</code>
            <code>npm run dev</code>
            <br />
            <code># Build for production</code>
            <code>npm run build</code>
            <br />
            <code># Start production server</code>
            <code>npm start</code>
          </div>
        </div>
      </main>

      <footer className="footer">
        <p>© CURRENT_YEAR PROJECT_NAME. Built with OpenClaw Scaffolding Engine.</p>
        <p className="footer-links">
          <a href="/api">API Documentation</a> • 
          <a href="/api/health">Health Check</a> • 
          <a href="https://github.com/your-username/PROJECT_NAME">GitHub</a>
        </p>
      </footer>
    </div>
  )
}

export default App