// TypeScript type definitions for PROJECT_NAME client

// API Response Types
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export interface ApiResponse<T = unknown> {
  success: boolean
  data?: T
  error?: string
  message?: string
  timestamp: string
}

// Health Status
export interface HealthStatus {
  status: string
  timestamp: string
  service: string
  version: string
  uptime: string
  environment: string
  checks?: {
    api: string
    memory: {
      used: number
      total: number
      percentage: string
    }
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
  style?: React.CSSProperties
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

// All types are exported above