import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from 'axios'

const API_BASE_URL = import.meta.env.VITE_API_URL || '/api'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export interface ApiResponse<T = unknown> {
  success: boolean
  data?: T
  error?: string
  message?: string
  timestamp: string
}

class ApiClient {
  private client: AxiosInstance

  constructor() {
    this.client = axios.create({
      baseURL: API_BASE_URL,
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    })

    // Request interceptor
    this.client.interceptors.request.use(
      (config: InternalAxiosRequestConfig) => {
        // Add auth token if available
        const token = localStorage.getItem('token')
        if (token) {
          config.headers.Authorization = `Bearer ${token}`
        }
        return config
      },
      (error: unknown) => {
        return Promise.reject(error)
      }
    )

    // Response interceptor
    this.client.interceptors.response.use(
      (response: AxiosResponse) => response,
      (error: unknown) => {
        if (axios.isAxiosError(error) && error.response?.status === 401) {
          // Handle unauthorized
          localStorage.removeItem('token')
          window.location.href = '/login'
        }
        return Promise.reject(error)
      }
    )
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  async get<T = unknown>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<ApiResponse<T>> = await this.client.get(url, config)
    return this.handleResponse(response)
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  async post<T = unknown>(url: string, data?: unknown, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<ApiResponse<T>> = await this.client.post(url, data, config)
    return this.handleResponse(response)
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  async put<T = unknown>(url: string, data?: unknown, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<ApiResponse<T>> = await this.client.put(url, data, config)
    return this.handleResponse(response)
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  async delete<T = unknown>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<ApiResponse<T>> = await this.client.delete(url, config)
    return this.handleResponse(response)
  }

  private handleResponse<T>(response: AxiosResponse<ApiResponse<T>>): T {
    const { data } = response
    
    if (!data.success) {
      throw new Error(data.error || 'Request failed')
    }
    
    return data.data as T
  }
}

export const api = new ApiClient()
