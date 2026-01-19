// Back to Top Button
// Shows only when scrolling UP (to help users get to top quickly)
// Hides when scrolling down

document.addEventListener('DOMContentLoaded', function () {
    const button = document.querySelector('.back-to-top');
    if (!button) return;

    const showThreshold = 300; // pixels - must scroll down this far first
    let lastScrollY = window.scrollY;
    let isVisible = false;

    // Show/hide based on scroll direction
    function toggleButton() {
        const currentScrollY = window.scrollY;
        const scrollingUp = currentScrollY < lastScrollY;

        // Only show if scrolled past threshold AND scrolling up
        if (currentScrollY > showThreshold && scrollingUp) {
            if (!isVisible) {
                button.classList.add('visible');
                isVisible = true;
            }
        } else {
            if (isVisible) {
                button.classList.remove('visible');
                isVisible = false;
            }
        }

        lastScrollY = currentScrollY;
    }

    // Smooth scroll to top
    button.addEventListener('click', function () {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });

    // Listen for scroll events (throttled)
    let ticking = false;
    window.addEventListener('scroll', function () {
        if (!ticking) {
            window.requestAnimationFrame(function () {
                toggleButton();
                ticking = false;
            });
            ticking = true;
        }
    });
});
