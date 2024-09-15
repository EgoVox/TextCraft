# TextCraft

**TextCraft** est une plateforme d'écriture en ligne où les utilisateurs peuvent créer, lire et partager des histoires. Le projet est développé en Ruby on Rails et propose des fonctionnalités telles que l'analyse automatique de la qualité du texte, la gestion des chapitres, et l'évaluation de l'intérêt du récit via GPT.

## Fonctionnalités

- **Création d'histoires** : Les utilisateurs peuvent écrire et publier leurs histoires en plusieurs chapitres.
- **Analyse de texte** : Un système d'analyse basé sur l'API GPT évalue la lisibilité et l'intérêt du texte.
- **Suggestions d'amélioration** : En fonction du score, l'analyse fournit des suggestions pour améliorer la qualité du récit.
- **Inscription et authentification des utilisateurs** : Les utilisateurs peuvent créer un compte, se connecter et gérer leur profil.
- **Commentaires et likes** : Les utilisateurs peuvent commenter et aimer les histoires.

## Technologies

Le projet est construit avec les technologies suivantes :

- **Ruby on Rails** : Framework backend
- **PostgreSQL** : Base de données
- **Heroku** : Déploiement de l'application
- **Devise** : Gestion de l'authentification des utilisateurs
- **GPT (OpenAI API)** : Analyse et évaluation du texte
- **Stimulus.js** : Gestion des interactions front-end
- **SASS** : Préprocesseur CSS pour le style

## Installation et configuration

1. **Cloner le dépôt Git :**

   ```bash
   git clone https://github.com/ton-utilisateur/textcraft.git
   cd textcraft

2. **Installer les dépendances :**

   bundle install

3. **Configurer la base de données :**

   rails db:create
   rails db:migrate

4. **Lancer le serveur**

   rails s

Auteur : Stéphane LOTIES
