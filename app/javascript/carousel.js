document.addEventListener("DOMContentLoaded", function() {
  // Récupérer tous les carousels sur la page
  const carousels = document.querySelectorAll('.carousel-container');

  carousels.forEach(carousel => {
    // Récupérer les boutons de navigation
    const leftButton = carousel.querySelector('.carousel-button.left');
    const rightButton = carousel.querySelector('.carousel-button.right');
    const itemsContainer = carousel.querySelector('.carousel');

    // Ajouter les écouteurs d'événements pour les boutons
    leftButton.addEventListener('click', () => {
      itemsContainer.scrollBy({
        left: -300, // Ajuster la valeur selon la largeur d'un item
        behavior: 'smooth'
      });
    });

    rightButton.addEventListener('click', () => {
      itemsContainer.scrollBy({
        left: 300, // Ajuster la valeur selon la largeur d'un item
        behavior: 'smooth'
      });
    });
  });
});
