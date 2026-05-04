import request from 'supertest'
import app from '../src/index'

describe('Health Check Endpoints', () => {
  it('GET /health should return health status', async () => {
    const res = await request(app).get('/health')
    expect(res.statusCode).toEqual(200)
    expect(res.body).toHaveProperty('status', 'healthy')
    expect(res.body).toHaveProperty('timestamp')
    expect(res.body).toHaveProperty('service', 'PROJECT_NAME-server')
  })

  it('GET /api/health should return health status', async () => {
    const res = await request(app).get('/api/health')
    expect(res.statusCode).toEqual(200)
    expect(res.body).toHaveProperty('status', 'healthy')
  })

  it('GET /api should return API info', async () => {
    const res = await request(app).get('/api')
    expect(res.statusCode).toEqual(200)
    expect(res.body).toHaveProperty('message', 'Welcome to PROJECT_NAME API')
  })
})