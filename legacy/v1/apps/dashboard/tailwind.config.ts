import type { Config } from 'tailwindcss';

const config: Config = {
  darkMode: 'class',
  content: [
    './app/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    '../../packages/ui/src/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        canvas:  { DEFAULT: '#09090b', foreground: '#fafafa' },
        surface: { DEFAULT: '#111113', raised: '#18181b' },
        border:  { DEFAULT: '#27272a', subtle: '#3f3f46' },
        brand: {
          emerald: { DEFAULT: '#10b981', hover: '#059669', muted: '#064e3b' },
          amber:   { DEFAULT: '#f59e0b', hover: '#d97706', muted: '#78350f' },
        },
        text: {
          primary:   '#fafafa',
          secondary: '#a1a1aa',
          muted:     '#71717a',
        },
      },
      fontFamily: {
        sans: ['Inter Variable', 'Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      fontSize: {
        xs: ['0.75rem', { lineHeight: '1rem' }],
        sm: ['0.875rem', { lineHeight: '1.25rem' }],  // default body
        base: ['1rem', { lineHeight: '1.5rem' }],
      },
      animation: {
        shimmer: 'shimmer 1.5s infinite',
      },
      keyframes: {
        shimmer: {
          '0%': { backgroundPosition: '-200% 0' },
          '100%': { backgroundPosition: '200% 0' },
        },
      },
    },
  },
  plugins: [],
};

export default config;
