// Theme toggle functionality
(function() {
  const themeToggle = document.getElementById('theme-toggle');
  const html = document.documentElement;
  
  // Check for saved theme preference or default to light mode
  const currentTheme = localStorage.getItem('theme') || 'light';
  
  // Apply the current theme
  if (currentTheme === 'dark') {
    html.classList.add('dark');
  } else {
    html.classList.remove('dark');
  }
  
  // Update toggle button text
  function updateToggleText() {
    if (themeToggle) {
      themeToggle.textContent = html.classList.contains('dark') ? '☀️' : '🌙';
    }
  }
  
  updateToggleText();
  
  // Toggle theme function
  function toggleTheme() {
    if (html.classList.contains('dark')) {
      html.classList.remove('dark');
      localStorage.setItem('theme', 'light');
    } else {
      html.classList.add('dark');
      localStorage.setItem('theme', 'dark');
    }
    updateToggleText();
  }
  
  // Add event listener to toggle button
  if (themeToggle) {
    themeToggle.addEventListener('click', toggleTheme);
  }
})(); 