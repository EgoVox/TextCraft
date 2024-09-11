document.addEventListener("DOMContentLoaded", function () {
  const categoriesToggle = document.getElementById("categoriesDropdown");
  const categoriesMenu = document.querySelector(".header-categories-dropdown");

  // Afficher / cacher le menu des catégories au clic
  categoriesToggle.addEventListener("click", function (event) {
    event.preventDefault();
    categoriesMenu.classList.toggle("show");
  });

  // Fermer le menu si on clique ailleurs sur la page
  document.addEventListener("click", function (event) {
    if (!categoriesMenu.contains(event.target) && event.target !== categoriesToggle) {
      categoriesMenu.classList.remove("show");
    }
  });
});
