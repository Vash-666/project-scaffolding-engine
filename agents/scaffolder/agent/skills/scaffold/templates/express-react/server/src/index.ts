import express, { Request, Response } from 'express'
import cors from 'cors'
import helmet from 'helmet'
import morgan from 'morgan'
import { errorHandler, notFound } from './middleware/errorHandler'
import { logger } from './middleware/logger'
import routes from './routes'

const app = express()
const PORT = process.env.PORT || 3001

// Middleware
app.use(helmet())
app.use(cors({
  origin: process.env.CLIENT_URL || 'http://localhost:3000',
  credentials: true,
}))
app.use(morgan('combined'))
app.use(express.json())
app.use(express.urlencoded({ extended: true }))
app.use(logger)

// Routes
app.use('/api', routes)

// Health check endpoint
app.get('/health', (req: Request, res: Response) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'PROJECT_NAME-server',
    version: '0.1.0',
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
  })
})

// Error handling
app.use(notFound)
app.use(errorHandler)

// Start server
if (process.env.NODE_ENV !== 'test') {
  // eslint-disable-next-line no-console
  app.listen(PORT, () => console.log(`Server running on port ${PORT}`))
}

export default app