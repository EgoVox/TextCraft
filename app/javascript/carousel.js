  function scrollCarousel(direction) {
    const carousel = document.querySelector('.carousel');
    const scrollAmount = 320; // Ajuster cette valeur en fonction de la largeur des cartes

    if (direction === 'left') {
      carousel.scrollBy({ left: -scrollAmount, behavior: 'smooth' });
    } else {
      carousel.scrollBy({ left: scrollAmount, behavior: 'smooth' });
    }
  }
