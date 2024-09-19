import { getOppositeColor } from 'color_utils';

// Fonction pour générer une couleur plus sombre
function darkenColor(color, amount) {
  const colorValue = parseInt(color.slice(1), 16); // Supprime le "#" et convertit en nombre entier
  let r = (colorValue >> 16) - amount;
  let g = ((colorValue >> 8) & 0x00FF) - amount;
  let b = (colorValue & 0x0000FF) - amount;

  // Limiter les valeurs de couleur pour rester dans le range valide
  r = Math.max(Math.min(r, 255), 0);
  g = Math.max(Math.min(g, 255), 0);
  b = Math.max(Math.min(b, 255), 0);

  return `#${(r << 16 | g << 8 | b).toString(16).padStart(6, '0')}`;
}

// Fonction pour injecter les styles immédiatement dans le <head>
function injectStyles(primaryColor, oppositeColor, darkColor) {
  let style = document.querySelector('#dynamic-styles');
  if (!style) {
    style = document.createElement('style');
    style.id = 'dynamic-styles';
    document.head.appendChild(style);
  }

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

  // Mettre à jour l'aperçu du bouton
  const colorPickerButton = document.getElementById('color-picker-button');
  if (colorPickerButton) {
    colorPickerButton.style.backgroundColor = color;
  }
}

// Charger la couleur sauvegardée au chargement de la page
document.addEventListener('DOMContentLoaded', () => {
  const savedColor = localStorage.getItem('primaryColor') || '#ff6f61';
  const savedOppositeColor = localStorage.getItem('oppositeColor');

  // Appliquer les couleurs sauvegardées immédiatement si elles existent
  if (savedColor && savedOppositeColor) {
    const darkColor = darkenColor(savedColor, 20);
    injectStyles(savedColor, savedOppositeColor, darkColor);
  }

  // Sélecteur pour l'input de couleur
  const colorPicker = document.getElementById('primaryColorPicker');
  const colorPickerButton = document.getElementById('color-picker-button');

  // Initialiser la valeur du color picker
  if (colorPicker) {
    // Assigner la couleur sauvegardée ou la valeur par défaut
    colorPicker.value = savedColor;

    colorPicker.addEventListener('input', function(event) {
      const newColor = event.target.value;
      applyPrimaryColor(newColor);
    });
  }

  // Afficher le color picker lors du clic sur le bouton
  if (colorPickerButton) {
    colorPickerButton.style.backgroundColor = savedColor; // Définir la couleur initiale du bouton
    colorPickerButton.addEventListener('click', function() {
      if (colorPicker) {
        // Ouvrir le color picker natif
        colorPicker.click();
      }
    });
  }
});
