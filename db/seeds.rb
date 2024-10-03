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
  { name: "Poésie", description: "Pour les collections de poèmes ou d'écrits lyriques." },
  { name: "Enfants", description: "Pour les histoires pour enfants, petits et grands." }
])

# Création des utilisateurs
users = [
  { first_name: 'Alex', last_name: 'Martin', username: 'maartin', city: 'Marseille', email: 'alex.martin@example.com', gender: 'Masculin', bio: 'Alex Martin est un écrivain marseillais spécialisé dans les récits maritimes et les aventures historiques. Ses œuvres transportent les lecteurs à travers les mers du globe.', password: 'azerty' },
  { first_name: 'Samira', last_name: 'Lopez', username: 'salopez', city: 'Rennes', email: 'samira.lopez@example.com', gender: 'Féminin', bio: 'Spécialiste de la fantasy épique, Samira crée des univers où la magie et les légendes s\'entremêlent.', password: 'azerty' },
  { first_name: 'Julie', last_name: 'Wang', username: 'wangji', city: 'Bordeaux', email: 'julie.wang@example.com', gender: 'Féminin', bio: 'Passionnée par les mythes et contes anciens, Julie crée des récits où la légende se mêle à l\'aventure.', password: 'azerty' },
  { first_name: 'Fatou', last_name: 'Diarra', username: 'fiarradatou', city: 'Lyon', email: 'fatou.diarra@example.com', gender: 'Féminin', bio: 'Fatou est une autrice lyonnaise qui écrit sur les défis de la vie moderne, en combinant humour et réflexions profondes sur les relations humaines.', password: 'azerty' },
  { first_name: 'Camille', last_name: 'Dupont', username: 'cdupont', city: 'Genève', email: 'camille.dupont@example.com', gender: 'Féminin', bio: 'Camille explore la frontière entre le virtuel et la réalité dans ses récits de science-fiction dystopique.', password: 'azerty' },
  { first_name: 'Malik', last_name: 'Gharbi', username: 'mgharbi', city: 'Paris', email: 'malik.gharbi@example.com', gender: 'Masculin', bio: 'Astrophysicien et écrivain, Malik mêle science et imagination pour explorer les futurs dystopiques.', password: 'azerty' },
  { first_name: 'Leila', last_name: 'Sanchez', username: 'leisanch', city: 'Bordeaux', email: 'leila.sanchez@example.com', gender: 'Féminin', bio: 'Leila Sanchez, passionnée d\'Histoire et d\'aventure, aime écrire des récits où ses personnages font face à des dilemmes épiques.', password: 'azerty' },
  { first_name: 'Elias', last_name: 'Moreau', username: 'eliasM', city: 'Lyon', email: 'elias.moreau@example.com', gender: 'Masculin', bio: 'Spécialisé dans les thrillers, Elias écrit des récits pleins de suspense et de rebondissements inattendus.', password: 'azerty' },
  { first_name: 'Amina', last_name: 'Benkacem', username: 'amina_benkacem', city: 'Lille', email: 'amina.benkacem@example.com', gender: 'Féminin', bio: 'Amina aime les thrillers psychologiques qui plongent ses personnages dans des dilemmes moraux sombres et complexes.', password: 'azerty' },
  { first_name: 'Noah', last_name: 'Silva', username: 'noah_silva', city: 'Nantes', email: 'noah.silva@example.com', gender: 'Féminin', bio: 'Noah est une poétesse et romancière basée à Nantes, spécialisée dans l\'exploration des émotions humaines à travers la poésie moderne et les histoires de vie.', password: 'azerty' },
  { first_name: 'Sofia', last_name: 'Fernandez', username: 'SofiaF', city: 'Marseille', email: 'sofia.fernandez@example.com', gender: 'Féminin', bio: 'Sofia écrit des romances modernes avec une touche réaliste, inspirées de ses propres expériences de voyage.', password: 'azerty' },
  { first_name: 'Kylian', last_name: 'Adebayo', username: 'kyky', city: 'Montpellier', email: 'kylian.adebayo@example.com', gender: 'Masculin', bio: 'Kylian, basé à Montpellier, Léa Martin plonge ses lecteurs dans des histoires d\'amour complexes et émouvantes.', password: 'azerty' },
  { first_name: 'Yara', last_name: 'Cohen', username: 'yara_cohen', city: 'Paris', email: 'yara.cohen@example.com', gender: 'Masculin', bio: 'Yara Cohen, auteur parisien, explore les thèmes du drame social et de l\'injustice, à travers des récits poignants et profondément humains.', password: 'azerty' },
  { first_name: 'Maël', last_name: 'Lefebvre', username: 'maeeeel', city: 'Lille', email: 'mael.lefebvre@example.com', gender: 'Féminin', bio: 'Maël Lefebvre est une autrice spécialisée dans l\'horreur, avec des récits qui jouent sur la peur de l\'inconnu et de l\'invisible.', password: 'azerty' },
  { first_name: 'Zineb', last_name: 'Khalil', username: 'zineb_K', city: 'Rouen', email: 'zineb.khalil@example.com', gender: 'Féminin', bio: 'Zineb, spécialiste de l\'horreur psychologique, aime capturer l\'effroi à travers des histoires angoissantes et mystérieuses.', password: 'azerty' },
  { first_name: 'Théo', last_name: 'Nguyen', username: 'théo_nguyen', city: 'Lille', email: 'theo.nguyen@example.com', gender: 'Masculin', bio: 'Théo, originaire de Lille, est un auteur de comédies romantiques légères où l\'humour et les émotions se mêlent parfaitement.', password: 'azerty' },
  { first_name: 'Ilana', last_name: 'Haddad', username: 'ilanah', city: 'Nantes', email: 'ilana.haddad@example.com', gender: 'Féminin', bio: 'Ilana aime écrire des histoires d\'aventures maritimes, où ses personnages doivent faire face à des tempêtes et des défis impossibles.', password: 'azerty' },
  { first_name: 'Maxime', last_name: 'Rousseau', username: 'maxime_rousseau', city: 'Lyon', email: 'max.rousseau@example.com', gender: 'Masculin', bio: 'Maxime plonge ses lecteurs dans des récits d\'aventures palpitants, où les héros bravent des dangers pour découvrir des secrets enfouis.', password: 'azerty' },
  { first_name: 'Rania', last_name: 'Belaid', username: 'Ra_bel', city: 'Lyon', email: 'rania.belaid@example.com', gender: 'Féminin', bio: 'Rania s\'inspire des moments du quotidien pour écrire des comédies légères et pleines d\'humour.', password: 'azerty' },
  { first_name: 'Sacha', last_name: 'Duran', username: 'sacha_duran', city: 'Paris', email: 'sacha.duran@example.com', gender: 'Féminin', bio: 'Sacha maîtrise l\'art de la comédie avec ses récits hilarants où les personnages se retrouvent dans des situations absurdes et cocasses.', password: 'azerty' },
  { first_name: 'Ibrahim', last_name: 'Mansouri', username: 'ibra_mansouri', city: 'Nice', email: 'ibrahim.mansouri@example.com', gender: 'Masculin', bio: 'Ibrahim écrit des drames émotionnels qui abordent la perte, le deuil et la réconciliation.', password: 'azerty' },
  { first_name: 'Salomé', last_name: 'Pierre', username: 'Spierre', city: 'Toulouse', email: 'salomé.pierre@example.com', gender: 'Féminin', bio: 'Salomé est une autrice dramatique qui explore la résilience et les relations complexes à travers ses récits poignants.', password: 'azerty' },
  { first_name: 'Amadou', last_name: 'Kone', username: 'amadou_kone', city: 'Lille', email: 'amadou.kone@example.com', gender: 'Masculin', bio: 'Amadou exprime dans ses poèmes la complexité des sentiments humains, notamment l\'amour, la tristesse et l\'espoir.', password: 'azerty' },
  { first_name: 'Jade', last_name: 'Boukhalfa', username: 'jade-bou', city: 'Avignon', email: 'jade.boukhalfa@example.com', gender: 'Féminin', bio: 'Poétesse sensible, Jade capte la beauté de la nature et des émotions humaines à travers des vers évocateurs.', password: 'azerty' },
  { first_name: 'Attika', last_name: 'Matar', username: 'AttikaMatar', city: 'Limoges', email: 'attika.matar@example.com', gender: 'Féminin', bio: 'Attika est une touche à tout de l’écriture, des comptes pour enfants aux histoires pour adultes, elle s\'essaye et réussit tout.', password: 'azerty' },
  { first_name: 'Nathalie', last_name: 'Durand', username: 'camdurand', city: 'Lyon', email: 'nathalie.durand@example.com', gender: 'Féminin', bio: 'Nathalie aime l’univers des enfants et le montre à travers ses histoires aussi audacieuses qu\'enchanteresses.', password: 'azerty' }
]

users.each do |user_data|
  User.create!(user_data)
end


# clara.borel@example.com -
# nathan.duval@example.com -
# clara.dupont@example.com -
# lea.martin@example.com -
# thomas.dupuis@example.com -
# elodie.leclerc@example.com -
# camille.durand@example.com -
# etienne.lefevre@example.com -
# lucas.meunier@example.com -
# sophie.leroy@example.com -
# julien.caron@example.com -
# chloe.bernard@example.com -
# clara.dupuis@example.com -
# amelie.durieux@example.com -
# leon.montreuil@example.com -
# vincent.perrot@example.com -
# julie.roux@example.com -
# sarah.lefebvre@example.com -
# claire.moreau@example.com -
# alexandre.dumont@example.com -
# elwin.faure@example.com -
# luc.girard@example.com -
# emma.dupont@example.com -
# stephane@wivzem.fr -
# thomas.travis@example.com -
# elphine.langlet@hotmail.fr -
# stepha=> loties@gmail.com -
# damien.leclerc@example.com -
# antoine.morel@example.com -
# mael.gauthier@example.com
