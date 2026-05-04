// TypeScript type definitions for PROJECT_NAME

// API Response Types
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export interface ApiResponse<T = unknown> {
  success: boolean
  data?: T
  error?: string
  message?: string
  timestamp: string
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: {
    page: number
    limit: number
    total: number
    totalPages: number
    hasNext: boolean
    hasPrev: boolean
  }
}

// User Types
export interface User {
  id: string
  email: string
  name: string
  role: UserRole
  createdAt: string
  updatedAt: string
}

export type UserRole = 'admin' | 'user' | 'guest'

// Form Types
export interface LoginFormData {
  email: string
  password: string
  rememberMe?: boolean
}

export interface RegisterFormData {
  name: string
  email: string
  password: string
  confirmPassword: string
}

// Component Props
export interface BaseComponentProps {
  className?: string
  children?: React.ReactNode
}

export interface ButtonProps extends BaseComponentProps {
  variant?: 'default' | 'destructive' | 'outline' | 'secondary' | 'ghost' | 'link'
  size?: 'default' | 'sm' | 'lg' | 'icon'
  disabled?: boolean
  onClick?: () => void
  type?: 'button' | 'submit' | 'reset'
}

export interface CardProps extends BaseComponentProps {
  variant?: 'default' | 'outline'
}

// API Health
export interface HealthCheck {
  status: string
  timestamp: string
  service: string
  version: string
  uptime: string
  environment: string
  checks: {
    api: string
    database: string
    memory: {
      used: number
      total: number
      percentage: string
    }
  }
}

// Database Types
export interface DatabaseConfig {
  host: string
  port: number
  database: string
  username: string
  password: string
  ssl?: boolean
}

// Error Types
export interface AppError {
  code: string
  message: string
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  details?: unknown
  timestamp: string
}

// Feature Flags
export interface FeatureFlags {
  enableAnalytics: boolean
  enableDebug: boolean
  enableMaintenanceMode: boolean
  [key: string]: boolean
}

// Utility Types
export type Nullable<T> = T | null
export type Optional<T> = T | undefined
export type Maybe<T> = T | null | undefined

// Generic Types
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type Dictionary<T = unknown> = Record<string, T>
export type StringDictionary = Dictionary<string>
export type NumberDictionary = Dictionary<number>

// React Hook Types
export type SetState<T> = React.Dispatch<React.SetStateAction<T>>
export type UseStateReturn<T> = [T, SetState<T>]

// Event Types
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export interface ChangeEvent<T = HTMLInputElement> {
  target: {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    value: T extends HTMLInputElement ? string : unknown
    name?: string
    type?: string
    checked?: boolean
  }
}

// Export all types
