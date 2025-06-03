// Theme toggle functionality
(function() {
  const themeToggle = document.getElementById('theme-toggle');
  const themeIcon = document.getElementById('theme-icon');
  const html = document.documentElement;
  
  // Check for saved theme preference or default to light mode
  const currentTheme = localStorage.getItem('theme') || 'light';
  
  // Apply the current theme
  if (currentTheme === 'dark') {
    html.classList.add('dark');
  } else {
    html.classList.remove('dark');
  }
  
  // Update icon based on current theme
  function updateThemeIcon() {
    if (themeIcon) {
      themeIcon.textContent = html.classList.contains('dark') ? '☀️' : '🌙';
    }
  }
  
  // Initialize icon
  updateThemeIcon();
  
  // Toggle theme function
  function toggleTheme() {
    if (html.classList.contains('dark')) {
      html.classList.remove('dark');
      localStorage.setItem('theme', 'light');
    } else {
      html.classList.add('dark');
      localStorage.setItem('theme', 'dark');
    }
    updateThemeIcon();
  }
  
  // Add event listener to toggle button
  if (themeToggle) {
    themeToggle.addEventListener('click', toggleTheme);
  }
})(); 