document.addEventListener("DOMContentLoaded", function () {
  const searchButton = document.getElementById("searchDropdown"); // Bouton pour ouvrir le menu de recherche
  const searchMenu = document.getElementById("searchForm"); // Menu de recherche

  // Toggle du menu de recherche au clic
  searchButton.addEventListener("click", function (event) {
    event.stopPropagation(); // Empêche le clic de se propager pour éviter de fermer immédiatement le menu
    searchMenu.classList.toggle("show"); // Affiche ou masque le menu
  });

  // Ferme le menu de recherche en cliquant en dehors de celui-ci
  document.addEventListener("click", function (event) {
    if (!searchMenu.contains(event.target) && event.target !== searchButton) {
      searchMenu.classList.remove("show"); // Masque le menu si on clique à l'extérieur
    }
  });
});
