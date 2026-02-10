// Project Category Filter
document.addEventListener('DOMContentLoaded', function() {
    const filterButtons = document.querySelectorAll('.filter-btn');
    const projectCards = document.querySelectorAll('.project-card');
    const projectsGrid = document.querySelector('.projects-grid');

    // Set default active category
    const defaultCategory = 'all';
    setActiveCategory(defaultCategory);

    // Add click handlers to all filter buttons
    filterButtons.forEach(button => {
        button.addEventListener('click', function() {
            const category = this.getAttribute('data-category');
            filterProjects(category);
        });
    });

    function filterProjects(category) {
        // Add transitioning class for fade effect
        projectsGrid.classList.add('transitioning');

        // Update active button state
        filterButtons.forEach(btn => {
            if (btn.getAttribute('data-category') === category) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        });

        // Wait for fade out, then filter
        setTimeout(() => {
            projectCards.forEach(card => {
                const cardCategories = card.getAttribute('data-categories').split(' ');
                
                if (category === 'all' || cardCategories.includes(category)) {
                    card.classList.remove('hidden');
                    card.style.opacity = '0';
                    card.style.transform = 'translateY(10px)';
                } else {
                    card.classList.add('hidden');
                }
            });

            // Remove transitioning class
            projectsGrid.classList.remove('transitioning');

            // Animate visible cards in
            setTimeout(() => {
                projectCards.forEach(card => {
                    if (!card.classList.contains('hidden')) {
                        card.style.opacity = '1';
                        card.style.transform = 'translateY(0)';
                    }
                });
            }, 50);
        }, 150);
    }

    function setActiveCategory(category) {
        filterButtons.forEach(btn => {
            if (btn.getAttribute('data-category') === category) {
                btn.classList.add('active');
            }
        });

        // Show all cards initially
        projectCards.forEach(card => {
            card.classList.remove('hidden');
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
        });
    }
});