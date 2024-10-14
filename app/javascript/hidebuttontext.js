document.addEventListener('trix-initialize', function(event) {
  const toolbar = event.target.toolbarElement;

  // Cache les groupes d'outils texte et bloc
  toolbar.querySelector("[data-trix-button-group='text-tools']").style.display = 'none';
  toolbar.querySelector("[data-trix-button-group='block-tools']").style.display = 'none';

  // Ne garder que l'icône de pièce jointe
  toolbar.querySelector("[data-trix-button-group='file-tools'] [data-trix-action='attachFiles']").style.display = '';
});
