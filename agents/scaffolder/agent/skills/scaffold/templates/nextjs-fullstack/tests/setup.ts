import { expect, afterEach } from 'vitest'
import { cleanup } from '@testing-library/react'
import '@testing-library/jest-dom'

// Note: jest-dom matchers are automatically extended via the import above

// Run cleanup after each test case
afterEach(() => {
  cleanup()
})
