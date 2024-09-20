import { applyPrimaryColor } from './color_picker';

document.addEventListener('DOMContentLoaded', () => {
  document.body.classList.remove('loading');
});

document.addEventListener('DOMContentLoaded', () => {
  // Récupère la couleur de l'utilisateur depuis l'attribut `data-user-color`
  const userColor = document.body.getAttribute('data-user-color') || '#ff6f61';
  console.log("Couleur initiale appliquée:", userColor);
  applyPrimaryColor(userColor);
});
