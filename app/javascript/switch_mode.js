// Fonction pour basculer entre le mode sombre et clair
function toggleDarkMode() {
  document.body.classList.toggle('dark-mode');
  localStorage.setItem('darkMode', document.body.classList.contains('dark-mode'));
}

// Vérifie et applique le mode sombre sauvegardé au chargement de la page
window.addEventListener('load', function() {
  const isDarkMode = localStorage.getItem('darkMode') === 'true';
  if (isDarkMode) {
    document.body.classList.add('dark-mode');
  }
});

// Ajoute un bouton ou un élément pour basculer entre les modes
const darkModeToggle = document.getElementById('darkModeToggle');
if (darkModeToggle) {
  darkModeToggle.addEventListener('click', toggleDarkMode);
}
