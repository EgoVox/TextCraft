document.addEventListener('DOMContentLoaded', () => {
  const mobileMenuToggle = document.getElementById('mobileMenuToggle');
  const mobileMenu = document.getElementById('mobileMenu');

  // Toggle du menu mobile
  if (mobileMenuToggle) {
    mobileMenuToggle.addEventListener('click', (event) => {
      event.stopPropagation(); // Empêche la propagation de l'événement vers le document
      mobileMenu.classList.toggle('active');
    });

    // Fermer le menu lorsqu'on clique en dehors de celui-ci
    document.addEventListener('click', (event) => {
      if (!mobileMenu.contains(event.target) && !mobileMenuToggle.contains(event.target)) {
        mobileMenu.classList.remove('active');
      }
    });

    // Empêcher la propagation des clics à l'intérieur du menu
    mobileMenu.addEventListener('click', (event) => {
      event.stopPropagation(); // Empêche la fermeture du menu lorsqu'on clique dedans
    });
  }
});
