document.addEventListener('DOMContentLoaded', () => {
  const mobileMenuToggle = document.getElementById('mobileMenuToggle');
  const mobileMenu = document.getElementById('mobileMenu');
  const colorPickerButton = document.getElementById('color-picker-button');
  const primaryColorPicker = document.getElementById('primary-color-picker');

  // Toggle du menu mobile
  if (mobileMenuToggle) {
    mobileMenuToggle.addEventListener('click', () => {
      mobileMenu.classList.toggle('active');
    });

    // Fermer le menu lorsqu'on clique en dehors de celui-ci
    document.addEventListener('click', (event) => {
      if (!mobileMenu.contains(event.target) && !mobileMenuToggle.contains(event.target)) {
        mobileMenu.classList.remove('active');
      }
    });
  }

  // Afficher le color picker lorsqu'on clique sur le bouton
  if (colorPickerButton && primaryColorPicker) {
    colorPickerButton.addEventListener('click', () => {
      primaryColorPicker.click();
    });

    // Changer la couleur principale lorsqu'une couleur est sélectionnée
    primaryColorPicker.addEventListener('input', (event) => {
      document.documentElement.style.setProperty('--primary-color', event.target.value);
    });
  }
});
