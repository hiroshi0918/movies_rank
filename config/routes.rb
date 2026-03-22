Rails.application.routes.draw do
  devise_for :users

  root 'movies#index'
  resources :users, only: :show
  resources :movies, except: :index do
    resources :comments, only: :create
    resource :like, only: [:create, :destroy]
    collection do 
      get 'search'
      get 'rank'
    end
  end
end
