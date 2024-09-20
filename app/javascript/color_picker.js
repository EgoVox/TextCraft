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

  console.log('Injection des styles avec la couleur:', primaryColor);

  style.innerHTML = `
    :root {
      --primary-color: ${primaryColor} !important;
      --primary-hover-color: ${darkColor} !important;
      --opposite-color: ${oppositeColor} !important;
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
export function applyPrimaryColor(color) {
  console.log("Couleur appliquée:", color);
  const darkColor = darkenColor(color, 20); // Assombrir la couleur
  const oppositeColor = getOppositeColor(color); // Calculer la couleur opposée

  // Injecter les styles immédiatement
  injectStyles(color, oppositeColor, darkColor);
  console.log("Styles injectés avec couleur:", color, "couleur opposée:", oppositeColor, "couleur sombre:", darkColor);

  // Mettre à jour la base de données
  fetch('/users/update_color', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    },
    body: JSON.stringify({ user: { primary_color: color, opposite_color: oppositeColor } })
  }).then(response => {
    if (response.ok) {
      console.log("Couleur mise à jour avec succès");
    } else {
      console.error("Erreur lors de la mise à jour de la couleur");
    }
  });
}

// Sélecteur pour l'input de couleur
document.addEventListener('DOMContentLoaded', () => {
  const colorPicker = document.getElementById('primaryColorPicker');
  const colorPickerButton = document.getElementById('color-picker-button');

  if (colorPicker) {
    // Initialiser la valeur du color picker
    colorPicker.value = getComputedStyle(document.documentElement).getPropertyValue('--primary-color').trim();

    colorPicker.addEventListener('input', function(event) {
      const newColor = event.target.value;
      applyPrimaryColor(newColor);
    });
  }

  // Afficher le color picker lors du clic sur le bouton
  if (colorPickerButton) {
    colorPickerButton.style.backgroundColor = getComputedStyle(document.documentElement).getPropertyValue('--primary-color').trim(); // Définir la couleur initiale du bouton
    colorPickerButton.addEventListener('click', function() {
      if (colorPicker) {
        // Ouvrir le color picker natif
        colorPicker.click();
      }
    });
  }
});

export { getOppositeColor, darkenColor, injectStyles };
