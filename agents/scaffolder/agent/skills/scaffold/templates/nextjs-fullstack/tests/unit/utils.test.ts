import { describe, it, expect } from 'vitest'
import { formatDate, formatCurrency, truncateText, generateId, cn } from '@/lib/utils'

describe('Utility Functions', () => {
  describe('formatDate', () => {
    it('formats Date object correctly', () => {
      const date = new Date('2024-01-15')
      expect(formatDate(date)).toBe('January 15, 2024')
    })

    it('formats date string correctly', () => {
      expect(formatDate('2024-01-15')).toBe('January 15, 2024')
    })
  })

  describe('formatCurrency', () => {
    it('formats positive numbers', () => {
      expect(formatCurrency(1234.56)).toBe('$1,234.56')
    })

    it('formats zero', () => {
      expect(formatCurrency(0)).toBe('$0.00')
    })

    it('formats negative numbers', () => {
      expect(formatCurrency(-1234.56)).toBe('-$1,234.56')
    })
  })

  describe('truncateText', () => {
    it('returns original text when shorter than max length', () => {
      const text = 'Hello World'
      expect(truncateText(text, 20)).toBe(text)
    })

    it('truncates text when longer than max length', () => {
      const text = 'This is a very long text that needs to be truncated'
      expect(truncateText(text, 20)).toBe('This is a very long...')
    })

    it('handles empty string', () => {
      expect(truncateText('', 10)).toBe('')
    })
  })

  describe('generateId', () => {
    it('generates a string', () => {
      const id = generateId()
      expect(typeof id).toBe('string')
      expect(id.length).toBeGreaterThan(0)
    })

    it('generates unique IDs', () => {
      const id1 = generateId()
      const id2 = generateId()
      expect(id1).not.toBe(id2)
    })
  })

  describe('cn (class names utility)', () => {
    it('merges class names correctly', () => {
      expect(cn('class1', 'class2')).toBe('class1 class2')
    })

    it('handles conditional classes', () => {
      const result = cn('base', true && 'conditional', false && 'not-included')
      expect(result).toBe('base conditional')
    })

    it('handles Tailwind conflicts', () => {
      const result = cn('p-4 p-8', 'm-2')
      expect(result).toBe('p-8 m-2')
    })
  })
})