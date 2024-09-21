class ReplaceTagsWithNewList < ActiveRecord::Migration[6.0]
  def up
    # Liste complète des tags à garder (ancienne et nouvelle liste combinées)
    new_tags = [
      'Action', 'Agent secret', 'Amitié', 'Amour', 'Ange', 'Animaux',
      'Antagoniste', 'Anti-héros', 'Apocalypse', 'Aventure', 'Bénédiction',
      'Cathédrale', 'Chapelle', 'Château', 'Chevalier', 'Cimetière',
      'Cité perdue', 'Colère', 'Comédie', 'Comique', 'Conte', 'Conte de fée',
      'Contemporain', 'Cowboy', 'Croyance', 'Cyberpunk', 'Cyborg', 'Détective',
      'Dialogue', 'Dinosaure', 'Dieu', 'Déesse', 'Démon', 'Désert', 'Destin',
      'Drame', 'Dystopie', 'Eglise', 'Elfe', 'Enchantement', 'Enquête',
      'Epopée', 'Epique', 'Espace', 'Espion', 'Esprit', 'Espoir',
      'Extraterrestre', 'Fable', 'Fantaisie urbaine', 'Fantastique', 'Fantôme',
      'Fantasy', 'Fée', 'Flashback', 'Folklore', 'Forêt enchantée',
      'Forteresse', 'Futuriste', 'Galaxie', 'Géant', 'Grotte', 'Guerre',
      'Héros', 'Histoire alternative', 'Historique', 'Horreur', 'Hôpital',
      'Humour', 'Imaginaire', 'Intelligence artificielle', 'Jungle', 'Journal',
      'Joie', 'Lac', 'Laboratoire', 'Légende', 'Légende arthurienne',
      'Légende urbaine', 'Liberté', 'Licorne', 'Loup-garou', 'Lugubre', 'Magie',
      'Maison hantée', 'Malédiction', 'Manoir', 'Marais', 'Mer', 'Méchant',
      'Mélancolie', 'Moderne', 'Monde parallèle', 'Monologue', 'Monstres',
      'Mort', 'Mordor', 'Mystère', 'Mystique', 'Mystérieux', 'Nain', 'Ninja',
      'Nouvelle', 'Océan', 'Orc', 'Parodie', 'Passé', 'Personnage',
      'Personnage principal', 'Personnage secondaire', 'Personnage tertiaire',
      'Peur', 'Pirate', 'Planète', 'Poétique', 'Poesie', 'Policier',
      'Post-apocalyptique', 'Pouvoirs', 'Poudlard', 'Présent', 'Prophète',
      'Protagoniste', 'Quête', 'Religion', 'Rédemption', 'Robot', 'Romance',
      'Romantique', 'Royaume', 'Saga', 'Samouraï', 'Sanctuaire', 'Satan',
      'Science Fiction', 'Sirène', 'Sortilège', 'Sorcière', 'Sorcier', 'Soldat',
      'Sombre', 'Spiritualité', 'Steampunk', 'Super-héros', 'Super-pouvoirs',
      'Super-vilain', 'Survival', 'Surréaliste', 'Surnaturel', 'Temple',
      'Temps', 'Terre', 'Terre du milieu', 'Thriller', 'Tour', 'Tragédie',
      'Tragique', 'Trahison', 'Tristesse', 'Troll', 'Université', 'Utopie',
      'Vampire', 'Viking', 'Vie', 'Voleur', 'Voyage', 'Voyage dans le temps',
      'Westeros', 'Zombie', 'Énigme', 'Épopée', 'Voyage épique',
      'Folklore asiatique', 'Folklore nordique', 'Sororité', 'Fraternité',
      'Passion', 'Exil', 'Renaissance', 'Tribus', 'Parallèle'
    ]

    # Suppression des anciens tags non présents dans la nouvelle liste
    Tag.where.not(name: new_tags).destroy_all

    # Ajout des nouveaux tags
    new_tags.each do |tag_name|
      Tag.find_or_create_by(name: tag_name)
    end
  end
end
