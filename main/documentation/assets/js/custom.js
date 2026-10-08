const body = document.querySelector('body'),
      btnToggleSidenav = document.querySelector('.btn-toggle-sidenav'),
      sidenav = document.querySelector('.doc-sidebar'),
      sidenavOverlay = document.querySelector('.doc-sidebar-overlay'),
      navLinks = document.querySelectorAll('.navbar-aside .nav-link');

const overflowHiddenWhileOpenSidebar = () => {
    if (sidenav.classList.contains('show-sidenav')) {
        body.style.overflowY = 'hidden';
    } else {
        body.style.overflowY = 'auto';
    }
}

const toggleSidenav = () => {
    sidenav.classList.toggle('show-sidenav');
    sidenavOverlay.classList.toggle('show-overlay');
}

btnToggleSidenav.addEventListener('click', (e) => {
    e.preventDefault();
    toggleSidenav();
    // overflowHiddenWhileOpenSidebar();
});

sidenavOverlay.addEventListener('click', (e) => {
    e.preventDefault();
    toggleSidenav();
    // overflowHiddenWhileOpenSidebar();
});

navLinks.forEach(link => {
    link.addEventListener('click', () => {
        toggleSidenav();
    });
})