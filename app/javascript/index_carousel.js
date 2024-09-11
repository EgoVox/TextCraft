document.addEventListener("DOMContentLoaded", function () {
  const carousel = document.querySelector(".carousel");
  const leftButton = document.querySelector(".carousel-button.left");
  const rightButton = document.querySelector(".carousel-button.right");

  const scrollStep = 200; // Taille du défilement en pixels

  // Vérifie que le carrousel et les boutons existent
  if (carousel && leftButton && rightButton) {
    rightButton.addEventListener("click", function () {
      carousel.scrollLeft += scrollStep;
    });

    leftButton.addEventListener("click", function () {
      carousel.scrollLeft -= scrollStep;
    });
  }
});
