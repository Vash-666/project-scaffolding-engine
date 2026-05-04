import { NextResponse } from 'next/server'

export async function GET() {
  const timestamp = new Date().toISOString()
  const uptime = process.uptime()
  
  const health = {
    status: 'healthy',
    timestamp,
    service: 'PROJECT_NAME',
    version: '1.0.0',
    uptime: `${Math.floor(uptime)} seconds`,
    environment: process.env.NODE_ENV || 'development',
    checks: {
      api: 'healthy',
      database: 'not_configured', // Would check actual database connection
      memory: {
        used: process.memoryUsage().heapUsed,
        total: process.memoryUsage().heapTotal,
        percentage: (process.memoryUsage().heapUsed / process.memoryUsage().heapTotal * 100).toFixed(2) + '%'
      }
    }
  }

  return NextResponse.json(health, {
    status: 200,
    headers: {
      'Cache-Control': 'no-store, no-cache, must-revalidate, proxy-revalidate',
      'Content-Type': 'application/json'
    }
  })
}

export async function HEAD() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Content-Type': 'application/json'
    }
  })
}