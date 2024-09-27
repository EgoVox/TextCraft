Rails.application.routes.draw do
  get 'pages/privacy'
  get 'pages/terms'
  get 'pages/contact'
  get 'pages/presentation'

  # Routes pour la gestion des utilisateurs avec Devise
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # Redirection après connexion (utilisateurs authentifiés)
  authenticated :user do
    root 'stories#index', as: :authenticated_root
  end

  # Redirection pour les utilisateurs non connectés (page d'accueil)
  unauthenticated do
    root 'home#index', as: :unauthenticated_root
  end

  # Routes pour les stories et les chapitres
  resources :stories do
    # Routes imbriquées pour les chapitres
    resources :chapters, except: [:index] do
      # Routes imbriquées pour les commentaires (sur les chapitres)
      resources :comments, only: [:create, :destroy]
    end

    # Routes imbriquées pour les commentaires (sur les stories)
    resources :comments, only: [:create, :destroy]

    # Route pour liker une histoire
    post 'like', to: 'likes#create'
    delete 'unlike', to: 'likes#destroy'
  end

  resources :stories, param: :id do
    member do
      post 'analyze', to: 'stories#analyze'
    end
  end

  resources :chapters do
    resources :comments, only: [:create, :destroy]
  end

  # Routes pour les catégories
  resources :categories, only: [:index, :show]

  # Routes pour voir le profil de l'utilisateur, ses histoires, etc.
  resources :users, only: [:show] do
    collection do
      post :update_color # Route personnalisée pour mettre à jour la couleur
    end
  end

  get 'search', to: 'stories#search', as: 'search_stories'

  # Pages statiques
  get 'privacy', to: 'pages#privacy'
  get 'terms', to: 'pages#terms'
  get 'contact', to: 'pages#contact'
  get 'presentation', to: 'pages#presentation'
end
