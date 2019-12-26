Rails.application.routes.draw do
  devise_for :views
  devise_for :users

  root 'movies#index'
  resources :users, only: :show
  resources :movies, except: :index do
    resources :comments, only: :create
    resources :likes, only: [:create, :destroy]
    collection do 
    get 'search'
    end
  end
end
