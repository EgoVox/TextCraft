document.addEventListener("DOMContentLoaded", function () {
  const userDropdownButton = document.getElementById("userDropdown");
  const userMenu = document.querySelector(".user-menu");
  const page = document.body.getAttribute('data-page');

  if (page !== 'home_index') {
    // Toggle dropdown menu on click
    userDropdownButton.addEventListener("click", function () {
      userMenu.classList.toggle("show");
    });

    // Close the menu if clicking outside
    document.addEventListener("click", function (event) {
      if (!userMenu.contains(event.target) && event.target !== userDropdownButton) {
        userMenu.classList.remove("show");
      }
    });
  }
});
