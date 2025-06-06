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
      },
      colors: {
        'primary-light': '#f0eee6',
        'primary-dark': '#1f1e1d',
        'text-light': '#1f1e1d',
        'text-dark': '#f0eee6',
        'click': '#3AA99F',
      },
      fontFamily: {
        'sans': ['Lato', 'Helvetica', 'Arial', 'sans-serif'],
        'serif': ['Georgia', 'Times New Roman', 'serif'],
      },
      fontSize: {
        'xl': '1.25rem', // 20px
        '2xl': '1.5rem',  // 24px
        '3xl': '2.25rem',  // 36px
        '4xl': '3rem',    // 48px
        'dario-title': ['2.5rem', { lineHeight: '1.1', fontWeight: '700' }],
        'dario-subtitle': ['1.25rem', { lineHeight: '1.3', fontWeight: '600' }],
        'dario-body': ['1rem', { lineHeight: '1.7' }],
        'dario-section': ['1.125rem', { lineHeight: '1.4', fontWeight: '600' }],
      }
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
} 