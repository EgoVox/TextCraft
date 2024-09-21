  // Fonction de défilement du carousel
function scrollCarousel(direction, carouselId) {
  var carousel = document.getElementById(carouselId);
  if (direction === 'left') {
    carousel.scrollLeft -= 300; // Ajustez la valeur pour changer la distance de défilement
  } else {
    carousel.scrollLeft += 300; // Ajustez la valeur pour changer la distance de défilement
  }
}
