class AddPredefinedTags < ActiveRecord::Migration[6.0]
  def change
    tags = [
    'Action', 'Agent secret', 'Amitié', 'Amour', 'Ange', 'Animaux', 'Antagoniste', 'Anti-héros', 'Apocalypse',
    'Aventure', 'Bénédiction', 'Cathédrale', 'Chapelle', 'Château', 'Chevalier', 'Cimetière', 'Cité perdue',
    'Colère', 'Comique', 'Conte', 'Conte de fée', 'Contemporain', 'Cowboy', 'Croyance', 'Cyberpunk',
    'Cyborg', 'Détective', 'Dialogue', 'Dinosaure', 'Dieu', 'Déesse', 'Démon', 'Désert', 'Destin',
    'Drame', 'Eglise', 'Elfe', 'Enchantement', 'Enquête', 'Epopée', 'Epique', 'Espace', 'Espion', 'Esprit',
    'Espoir', 'Extraterrestre', 'Fable', 'Fantastique', 'Fantôme', 'Fantasy', 'Fée', 'Flashback', 'Folklore',
    'Forêt enchantée', 'Forteresse', 'Futuriste', 'Galaxie', 'Géant', 'Grotte', 'Guerre', 'Héros', 'Historique',
    'Horreur', 'Hôpital', 'Humour', 'Imaginaire', 'Intelligence artificielle', 'Jungle', 'Journal', 'Joie',
    'Lac', 'Laboratoire', 'Légende', 'Légende arthurienne', 'Légende urbaine', 'Liberté', 'Licorne',
    'Loup-garou', 'Lugubre', 'Magie', 'Maison hantée', 'Malédiction', 'Manoir', 'Mer', 'Méchant',
    'Mélancolique', 'Moderne', 'Monde', 'Monologue', 'Monstres', 'Mort', 'Mordor', 'Mystère', 'Mystique',
    'Mystérieux', 'Narnia', 'Nain', 'Ninja', 'Nouvelle', 'Océan', 'Orc', 'Parodie', 'Personnage', 'Personnage principal',
    'Personnage secondaire', 'Personnage tertiaire', 'Peur', 'Pirate', 'Planète', 'Poétique', 'Poesie', 'Policier',
    'Post-apocalyptique', 'Pouvoirs', 'Poudlard', 'Prophète', 'Protagoniste', 'Quête', 'Religion', 'Rédemption',
    'Robot', 'Romance', 'Romantique', 'Royaume', 'Saga', 'Samouraï', 'Sanctuaire', 'Satan', 'Science Fiction',
    'Sirène', 'Sortilège', 'Sorcière', 'Sorcier', 'Soldat', 'Sombre', 'Spiritualité', 'Steampunk', 'Super-héros',
    'Super-pouvoirs', 'Super-vilain', 'Survival', 'Surréaliste', 'Surnaturel', 'Temple', 'Terre', 'Terre du milieu',
    'Thriller', 'Tour', 'Tragédie', 'Tragique', 'Trahison', 'Tristesse', 'Troll', 'Université', 'Vampire',
    'Viking', 'Vie', 'Voleur', 'Voyage dans le temps', 'Zombie'
    ]

    tags.each do |tag|
      Tag.find_or_create_by(name: tag)
    end
  end
end
