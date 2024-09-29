document.addEventListener("DOMContentLoaded", function() {
  const maxTags = 8;
  const predifinedTagSelect = document.querySelector('#story_predifined_tags');
  const suggestedTagInputs = document.querySelectorAll('input[name="story[suggested_tags][]"]');

  function updateTagCount() {
    const predifinedCount = predifinedTagSelect.selectedOptions.length;
    const suggestedCount = Array.from(suggestedTagInputs).filter(input => input.checked).length;

    const totalTagsCount = predifinedCount + suggestedCount;
    if (totalTagsCount > maxTags) {
      alert(`Vous pouvez sélectionner au maximum ${maxTags} tags au total.`);
      return false;
    }
    return true;
  }

  // Écouter les changements sur les deux listes
  predifinedTagSelect.addEventListener('change', updateTagCount);
  suggestedTagInputs.forEach(input => {
    input.addEventListener('change', updateTagCount);
  });
});
