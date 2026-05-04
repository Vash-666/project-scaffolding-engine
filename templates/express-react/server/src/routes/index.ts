import { Router } from 'express'
import healthRouter from './health'

const router = Router()

// API routes
router.use('/health', healthRouter)

// Default route
router.get('/', (req, res) => {
  res.json({
    message: 'Welcome to PROJECT_NAME API',
    version: '0.1.0',
    documentation: '/api/docs',
    health: '/api/health',
  })
})

export default router