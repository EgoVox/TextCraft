import { getOppositeColor } from 'color_utils';

// Fonction pour générer une couleur plus sombre
function darkenColor(color, amount) {
  const colorValue = parseInt(color.slice(1), 16); // Supprime le "#" et convertit en nombre entier
  let r = (colorValue >> 16) - amount;
  let g = ((colorValue >> 8) & 0x00FF) - amount;
  let b = (colorValue & 0x0000FF) - amount;

  r = Math.max(r, 0);
  g = Math.max(g, 0);
  b = Math.max(b, 0);

  return `#${(r << 16 | g << 8 | b).toString(16).padStart(6, '0')}`;
}

// Fonction pour injecter les styles immédiatement dans le <head>
function injectStyles(primaryColor, oppositeColor, darkColor) {
  const style = document.createElement('style');
  style.innerHTML = `
    :root {
      --primary-color: ${primaryColor};
      --primary-hover-color: ${darkColor};
    }
    .card-index__title_main a {
      color: ${oppositeColor} !important;
    }
    h1, h2, h3, h4, h5, h6 {
      color: ${oppositeColor};
    }
  `;
  document.head.appendChild(style);
}

// Fonction pour appliquer la couleur principale et la couleur opposée
function applyPrimaryColor(color) {
  const darkColor = darkenColor(color, 20); // Assombrir la couleur
  const oppositeColor = getOppositeColor(color); // Calculer la couleur opposée

  // Injecter les styles immédiatement
  injectStyles(color, oppositeColor, darkColor);

  // Sauvegarder les couleurs dans le localStorage
  localStorage.setItem('primaryColor', color);
  localStorage.setItem('oppositeColor', oppositeColor);
}

// Charger la couleur sauvegardée au chargement de la page
document.addEventListener('DOMContentLoaded', () => {
  const savedColor = localStorage.getItem('primaryColor');
  const savedOppositeColor = localStorage.getItem('oppositeColor');

  // Appliquer les couleurs sauvegardées immédiatement si elles existent
  if (savedColor && savedOppositeColor) {
    const darkColor = darkenColor(savedColor, 20);
    injectStyles(savedColor, savedOppositeColor, darkColor);
  }

  // Sélecteur pour l'input de couleur
  const colorPicker = document.getElementById('primaryColorPicker');

  // Écoute des changements de l'input color picker
  if (colorPicker) {
    colorPicker.value = savedColor || '#ff6f61'; // Valeur par défaut si aucune couleur n'est sauvegardée

    colorPicker.addEventListener('input', function(event) {
      const newColor = event.target.value;
      applyPrimaryColor(newColor);
    });
  }
});
