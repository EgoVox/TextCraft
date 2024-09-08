# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#
Category.destroy_all
User.destroy_all

Category.create([
  { name: "Fantasy", description: "Pour les histoires impliquant des éléments magiques ou surnaturels dans des mondes imaginaires." },
  { name: "Science-Fiction", description: "Pour les récits basés sur des avancées scientifiques ou technologiques dans des mondes futuristes ou alternatifs." },
  { name: "Mystère/Thriller", description: "Pour les histoires centrées sur des enquêtes, des crimes ou des éléments de suspense." },
  { name: "Romance", description: "Pour les histoires d'amour et de relations." },
  { name: "Horreur", description: "Pour les récits conçus pour effrayer ou créer une atmosphère de terreur." },
  { name: "Historique", description: "Pour les récits se déroulant dans des périodes historiques réelles." },
  { name: "Aventure", description: "Pour les récits centrés sur l'exploration, les quêtes ou les périples." },
  { name: "Comédie", description: "Pour les histoires légères ou humoristiques." },
  { name: "Drame", description: "Pour les récits émotionnels et réalistes." },
  { name: "Poésie", description: "Pour les collections de poèmes ou d'écrits lyriques." }
])

# Création des utilisateurs
users = [
  { first_name: 'Elwin', last_name: 'Faure', username: 'elwin_faure', city: 'Bordeaux', email: 'elwin.faure@example.com', gender: 'Masculin', bio: 'Passionné par les mythes et contes anciens, Elwin Faure crée des récits où la légende se mêle à l\'aventure.', password: 'azerty' },
  { first_name: 'Maëlys', last_name: 'Gauthier', username: 'mael_gauthier', city: 'Rennes', email: 'mael.gauthier@example.com', gender: 'Féminin', bio: 'Spécialiste de la fantasy épique, Maëlys Gauthier crée des univers où la magie et les légendes s\'entremêlent.', password: 'azerty' },
  { first_name: 'Nathan', last_name: 'Duval', username: 'nathan_duv', city: 'Paris', email: 'nathan.duval@example.com', gender: 'Masculin', bio: 'Nathan Duval, astrophysicien et écrivain, mêle science et imagination pour explorer les futurs dystopiques.', password: 'azerty' },
  { first_name: 'Clara', last_name: 'Borel', username: 'clara_borel', city: 'Genève', email: 'clara.borel@example.com', gender: 'Féminin', bio: 'Clara Borel explore la frontière entre le virtuel et la réalité dans ses récits de science-fiction dystopique.', password: 'azerty' },
  { first_name: 'Damien', last_name: 'Leclerc', username: 'damien_leclerc', city: 'Lille', email: 'damien.leclerc@example.com', gender: 'Masculin', bio: 'Damien Leclerc aime les thrillers psychologiques qui plongent ses personnages dans des dilemmes moraux sombres et complexes.', password: 'azerty' },
  { first_name: 'Clara', last_name: 'Dupont', username: 'clara_dupont', city: 'Lyon', email: 'clara.dupont@example.com', gender: 'Féminin', bio: 'Spécialisée dans les thrillers, Clara Dupont écrit des récits pleins de suspense et de rebondissements inattendus.', password: 'azerty' },
  { first_name: 'Léa', last_name: 'Martin', username: 'lea_martin', city: 'Montpellier', email: 'lea.martin@example.com', gender: 'Féminin', bio: 'Romancière basée à Montpellier, Léa Martin plonge ses lecteurs dans des histoires d\'amour complexes et émouvantes.', password: 'azerty' },
  { first_name: 'Thomas', last_name: 'Dupuis', username: 'thomas_dupuis', city: 'Marseille', email: 'thomas.dupuis@example.com', gender: 'Masculin', bio: 'Thomas Dupuis écrit des romances modernes avec une touche réaliste, inspirées de ses propres expériences de voyage.', password: 'azerty' },
  { first_name: 'Antoine', last_name: 'Morel', username: 'antoine_morel', city: 'Rouen', email: 'antoine.morel@example.com', gender: 'Masculin', bio: 'Antoine Morel, spécialiste de l\'horreur psychologique, aime capturer l\'effroi à travers des histoires angoissantes et mystérieuses.', password: 'azerty' },
  { first_name: 'Sarah', last_name: 'Lefebvre', username: 'sarah_lefebvre', city: 'Lille', email: 'sarah.lefebvre@example.com', gender: 'Féminin', bio: 'Sarah Lefebvre est une autrice spécialisée dans l\'horreur, avec des récits qui jouent sur la peur de l\'inconnu et de l\'invisible.', password: 'azerty' },
  { first_name: 'Camille', last_name: 'Durand', username: 'camille_durand', city: 'Bordeaux', email: 'camille.durand@example.com', gender: 'Féminin', bio: 'Camille Durand mêle Histoire et drame pour explorer la vie des gens ordinaires au cœur d\'événements extraordinaires.', password: 'azerty' },
  { first_name: 'Étienne', last_name: 'Lefèvre', username: 'etienne_lefevre', city: 'Paris', email: 'etienne.lefevre@example.com', gender: 'Masculin', bio: 'Étienne Lefèvre, ancien professeur d\'histoire, explore les dilemmes moraux dans ses récits historiques.', password: 'azerty' },
  { first_name: 'Lucas', last_name: 'Meunier', username: 'lucas_meunier', city: 'Lyon', email: 'lucas.meunier@example.com', gender: 'Masculin', bio: 'Lucas Meunier plonge ses lecteurs dans des récits d\'aventures palpitants, où les héros bravent des dangers pour découvrir des secrets enfouis.', password: 'azerty' },
  { first_name: 'Sophie', last_name: 'Leroy', username: 'sophie_leroy', city: 'Nantes', email: 'sophie.leroy@example.com', gender: 'Féminin', bio: 'Sophie Leroy aime écrire des histoires d\'aventures maritimes, où ses personnages doivent faire face à des tempêtes et des défis impossibles.', password: 'azerty' },
  { first_name: 'Julien', last_name: 'Caron', username: 'julien_caron', city: 'Paris', email: 'julien.caron@example.com', gender: 'Masculin', bio: 'Julien Caron maîtrise l\'art de la comédie avec ses récits hilarants où les personnages se retrouvent dans des situations absurdes et cocasses.', password: 'azerty' },
  { first_name: 'Chloé', last_name: 'Bernard', username: 'chloe_bernard', city: 'Lyon', email: 'chloe.bernard@example.com', gender: 'Féminin', bio: 'Chloé Bernard s\'inspire des moments du quotidien pour écrire des comédies légères et pleines d\'humour.', password: 'azerty' },
  { first_name: 'Clara', last_name: 'Dupuis', username: 'clara_dupuis', city: 'Toulouse', email: 'clara.dupuis@example.com', gender: 'Féminin', bio: 'Clara Dupuis est une autrice dramatique qui explore la résilience et les relations complexes à travers ses récits poignants.', password: 'azerty' },
  { first_name: 'Élodie', last_name: 'Leclerc', username: 'elodie_leclerc', city: 'Nice', email: 'elodie.leclerc@example.com', gender: 'Féminin', bio: 'Élodie Leclerc écrit des drames émotionnels qui abordent la perte, le deuil et la réconciliation.', password: 'azerty' },
  { first_name: 'Léon', last_name: 'Montreuil', username: 'leon_montreuil', city: 'Avignon', email: 'leon.montreuil@example.com', gender: 'Masculin', bio: 'Poète sensible, Léon Montreuil capte la beauté de la nature et des émotions humaines à travers des vers évocateurs.', password: 'azerty' },
  { first_name: 'Amélie', last_name: 'Durieux', username: 'amelie_durieux', city: 'Lille', email: 'amelie.durieux@example.com', gender: 'Féminin', bio: 'Amélie Durieux exprime dans ses poèmes la complexité des sentiments humains, notamment l\'amour, la tristesse et l\'espoir.', password: 'azerty' },
  { first_name: 'Vincent', last_name: 'Perrot', username: 'vincent_perrot', city: 'Marseille', email: 'vincent.perrot@example.com', gender: 'Masculin', bio: 'Vincent Perrot est un écrivain marseillais spécialisé dans les récits maritimes et les aventures historiques. Ses œuvres transportent les lecteurs à travers les mers du globe.', password: 'azerty' },
  { first_name: 'Julie', last_name: 'Roux', username: 'julie_roux', city: 'Lyon', email: 'julie.roux@example.com', gender: 'Féminin', bio: 'Julie Roux est une autrice lyonnaise qui écrit sur les défis de la vie moderne, en combinant humour et réflexions profondes sur les relations humaines.', password: 'azerty' },
  { first_name: 'Alexandre', last_name: 'Dumont', username: 'alexandre_dumont', city: 'Bordeaux', email: 'alexandre.dumont@example.com', gender: 'Masculin', bio: 'Alexandre Dumont, passionné d\'Histoire et d\'aventure, aime écrire des récits où ses personnages font face à des dilemmes épiques.', password: 'azerty' },
  { first_name: 'Claire', last_name: 'Moreau', username: 'claire_moreau', city: 'Nantes', email: 'claire.moreau@example.com', gender: 'Féminin', bio: 'Claire Moreau est une poétesse et romancière basée à Nantes, spécialisée dans l\'exploration des émotions humaines à travers la poésie moderne et les histoires de vie.', password: 'azerty' },
  { first_name: 'Luc', last_name: 'Girard', username: 'luc_girard', city: 'Paris', email: 'luc.girard@example.com', gender: 'Masculin', bio: 'Luc Girard, auteur parisien, explore les thèmes du drame social et de l\'injustice, à travers des récits poignants et profondément humains.', password: 'azerty' },
  { first_name: 'Emma', last_name: 'Dupont', username: 'emma_dupont', city: 'Lille', email: 'emma.dupont@example.com', gender: 'Féminin', bio: 'Emma Dupont, originaire de Lille, est une autrice de comédies romantiques légères où l\'humour et les émotions se mêlent parfaitement.', password: 'azerty' }
]

users.each do |user_data|
  User.create!(user_data)
end
