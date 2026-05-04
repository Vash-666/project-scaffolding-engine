import { Request, Response, NextFunction } from 'express'

export const logger = (req: Request, res: Response, next: NextFunction) => {
  const start = Date.now()
  
  res.on('finish', () => {
    const duration = Date.now() - start
    const message = `${req.method} ${req.originalUrl} ${res.statusCode} ${duration}ms`
    
    // eslint-disable-next-line no-console
    console.log(message)
  })
  
  next()
}