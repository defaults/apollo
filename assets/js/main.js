// Main JavaScript file
document.addEventListener('DOMContentLoaded', () => {
    console.log('Main JS loaded');
    // Add your JS code here
  });

// Mobile menu toggle
document.addEventListener('DOMContentLoaded', function() {
    const mobileMenuButton = document.getElementById('mobile-menu-button');
    const mobileMenu = document.getElementById('mobile-menu');
    
    if (mobileMenuButton && mobileMenu) {
        mobileMenuButton.addEventListener('click', function() {
            mobileMenu.classList.toggle('hidden');
        });
    }
    
    // Add smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href');
            if (targetId === '#') return;
            
            const targetElement = document.querySelector(targetId);
            if (targetElement) {
                targetElement.scrollIntoView({
                    behavior: 'smooth'
                });
            }
        });
    });
    
    // Add active class to current navigation item
    const currentPath = window.location.pathname;
    document.querySelectorAll('nav a').forEach(link => {
        const linkPath = link.getAttribute('href');
        if (linkPath === currentPath || 
            (currentPath.startsWith(linkPath) && linkPath !== '/' && currentPath !== '/')) {
            link.classList.add('text-blue-600', 'border-b-2', 'border-blue-600');
        }
    });

    // Make external links (those with arrow icons) open in new tab
    const externalLinks = document.querySelectorAll('article a:not(.plain):not(.tag):not(.internal-link):not(.footnote):not(.reversefootnote)');
    
    externalLinks.forEach(link => {
        const href = link.getAttribute('href');
        // Check if it's an external link (doesn't start with # or /)
        if (href && !href.startsWith('#') && !href.startsWith('/')) {
            link.setAttribute('target', '_blank');
            link.setAttribute('rel', 'noopener noreferrer');
        }
    });
});