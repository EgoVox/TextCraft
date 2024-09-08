Rails.application.routes.draw do
  # Routes pour la gestion des utilisateurs avec Devise
  devise_for :users

  # Route pour la page d'accueil (par exemple, un index des stories populaires)
  root 'stories#index'

  # Routes pour les stories et les chapitres
  resources :stories do
    # Routes imbriquées pour les chapitres
    resources :chapters, except: [:index]  # On n'a pas besoin d'indexer les chapitres séparément

    # Routes imbriquées pour les commentaires (sur les stories)
    resources :comments, only: [:create, :destroy]

    # Route pour liker une histoire
    post 'like', to: 'likes#create'
    delete 'unlike', to: 'likes#destroy'
  end

  resources :categories, only: [:index, :show]

  # Routes pour voir le profil de l'utilisateur, ses histoires, etc.
  resources :users, only: [:show]
end
