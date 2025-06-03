module.exports = {
  content: [
    './_layouts/**/*.html',
    './_includes/**/*.html',
    './_posts/**/*.{md,html}',
    './_publications/**/*.{md,html}',
    './content/**/*.{md,html}',
    './*.{md,html}',
    './assets/js/**/*.js'
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        'primary-light': '#f0eee6',
        'primary-dark': '#1f1e1d',
        'text-light': '#1f1e1d',
        'text-dark': '#f0eee6',
        'click': '#3AA99F',
      },
      fontFamily: {
        'serif': ['Georgia', 'Times New Roman', 'serif'],
        'sans': ['system-ui', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'sans-serif'],
      },
      maxWidth: {
        'content': '65ch',
      }
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
} 