document.addEventListener("DOMContentLoaded", function() {
  const maxTags = 5; // Par exemple, 5 tags maximum
  const tagSelect = document.querySelector('select[multiple]');
  const page = document.body.getAttribute('data-page');


  if (page !== 'home_index') {
    if (tagSelect) { // Vérifie que l'élément existe avant d'ajouter l'écouteur
      tagSelect.addEventListener('change', function() {
        if (tagSelect.selectedOptions.length > maxTags) {
          alert(`Vous pouvez sélectionner au maximum ${maxTags} tags.`);
          // Désélectionner le dernier ajouté
          Array.from(tagSelect.options).forEach(option => {
            if (option.selected && !Array.from(tagSelect.selectedOptions).includes(option)) {
              option.selected = false;
            }
          });
        }
      });
    } else {
      console.error("L'élément de sélection des tags n'existe pas sur cette page.");
    }
  }
});
