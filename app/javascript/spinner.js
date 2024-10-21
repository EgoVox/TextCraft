document.addEventListener('DOMContentLoaded', function() {
  const chapterForm = document.querySelector('.chapter-form');
  const loadingModal = document.getElementById('loading-modal');

  if (chapterForm) {
    console.log("Form found");

    chapterForm.addEventListener('submit', function(event) {
      // Affiche le modal lors de la soumission
      loadingModal.style.display = 'flex';
    });
  }

  // Masquer le modal après la soumission ou une erreur
  document.addEventListener('ajax:complete', function(event) {
    loadingModal.style.display = 'none';
  });

  document.addEventListener('ajax:error', function(event) {
    loadingModal.style.display = 'none';
  });

  // Si la soumission échoue, masque le modal après un délai
  setTimeout(function() {
    loadingModal.style.display = 'none';
  }, 5000); // Ajuste selon tes besoins
});
