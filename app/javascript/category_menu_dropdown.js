document.addEventListener("DOMContentLoaded", function () {
  const categoriesDropdownButton = document.getElementById("categoriesDropdown");
  const categoriesMenu = document.querySelector(".header-categories-dropdown");

  // Toggle dropdown menu on click
  categoriesDropdownButton.addEventListener("click", function () {
    categoriesMenu.classList.toggle("show");
  });

  // Close the menu if clicking outside
  document.addEventListener("click", function (event) {
    if (!categoriesMenu.contains(event.target) && event.target !== categoriesDropdownButton) {
      categoriesMenu.classList.remove("show");
    }
  });
});
