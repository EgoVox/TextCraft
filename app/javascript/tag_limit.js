document.addEventListener("DOMContentLoaded", function() {
  const maxTags = 8;
  const predifinedTagSelect = document.querySelector('#story_tag_ids'); // Vérifie que l'ID est correct
  const suggestedTagInputs = document.querySelectorAll('input[name="story[suggested_tags][]"]');

  // Fonction pour compter les tags sélectionnés
  function updateTagCount() {
    const predifinedCount = predifinedTagSelect ? predifinedTagSelect.selectedOptions.length : 0;
    const suggestedCount = Array.from(suggestedTagInputs).filter(input => input.checked).length;

    const totalTagsCount = predifinedCount + suggestedCount;
    if (totalTagsCount > maxTags) {
      alert(`Vous pouvez sélectionner au maximum ${maxTags} tags au total.`);
      return false;
    }
    return true;
  }

  // Si le select des tags prédéfinis existe, on ajoute l'écouteur
  if (predifinedTagSelect) {
    predifinedTagSelect.addEventListener('change', updateTagCount);
  }

  // Si les tags suggérés existent, on ajoute l'écouteur sur chacun d'eux
  if (suggestedTagInputs.length > 0) {
    suggestedTagInputs.forEach(input => {
      input.addEventListener('change', updateTagCount);
    });
  }
});
