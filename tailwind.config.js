/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './_includes/**/*.html',
    './_layouts/**/*.html',
    './_posts/**/*.md',
    './_posts/**/*.html',
    './*.html',
    './*.md',
    './content/**/*.md',
    './content/**/*.html',
    './assets/js/**/*.js'
  ],
  darkMode: 'class',
  theme: {
    extend: {
      maxWidth: {
        'content': '65ch',
        'wrap-normal': 'var(--wrap-normal)',
        'wrap-wide': 'var(--wrap-wide)',
      },
      colors: {
        // Flexoki base colors
        'primary-light': 'var(--color-bg-primary)',
        'primary-dark': 'var(--flexoki-black)',
        'text-light': 'var(--color-tx-normal)',
        'text-dark': 'var(--flexoki-200)',
        'click': 'var(--color-action)',
        
        // Flexoki semantic colors
        'bg-primary': 'var(--color-bg-primary)',
        'bg-secondary': 'var(--color-bg-secondary)',
        'tx-normal': 'var(--color-tx-normal)',
        'tx-muted': 'var(--color-tx-muted)',
        'tx-faint': 'var(--color-tx-faint)',
        'ui-normal': 'var(--color-ui-normal)',
        'ui-hover': 'var(--color-ui-hover)',
        'ui-active': 'var(--color-ui-active)',
        'action': 'var(--color-action)',
        
        // Flexoki absolute colors for fine control
        'flexoki-black': 'var(--flexoki-black)',
        'flexoki-paper': 'var(--flexoki-paper)',
        'flexoki-50': 'var(--flexoki-50)',
        'flexoki-100': 'var(--flexoki-100)',
        'flexoki-200': 'var(--flexoki-200)',
        'flexoki-300': 'var(--flexoki-300)',
        'flexoki-400': 'var(--flexoki-400)',
        'flexoki-500': 'var(--flexoki-500)',
        'flexoki-600': 'var(--flexoki-600)',
        'flexoki-700': 'var(--flexoki-700)',
        'flexoki-800': 'var(--flexoki-800)',
        'flexoki-900': 'var(--flexoki-900)',
        'flexoki-950': 'var(--flexoki-950)',
        
        // Color accents
        'cyan-400': 'var(--flexoki-cyan-400)',
        'cyan-600': 'var(--flexoki-cyan-600)',
        'blue-400': 'var(--flexoki-blue-400)',
        'blue-600': 'var(--flexoki-blue-600)',
      },
      fontFamily: {
        'content': 'var(--font-content)',
        'ui': 'var(--font-ui)',
        'mono': 'var(--font-mono)',
        'sans': ['var(--font-content)', 'system-ui', 'sans-serif'],
        'serif': ['Georgia', 'Times New Roman', 'serif'],
      },
      fontSize: {
        'small': 'var(--font-small)',
        'smaller': 'var(--font-smaller)',
        'xl': '1.25rem',
        '2xl': '1.5rem',
        '3xl': '2.25rem',
        '4xl': '3rem',
      },
      borderRadius: {
        'default': 'var(--border-radius)',
        'image': 'var(--image-radius)',
      },
      lineHeight: {
        'content': 'var(--line-height)',
      },
      fontWeight: {
        'heading': 'var(--heading-weight)',
      }
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
} 