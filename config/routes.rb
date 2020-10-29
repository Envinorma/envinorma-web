Rails.application.routes.draw do
  root 'installations#index'
  resources :installations
  get '/installations/:id/arretes', to: 'arretes#index', as: 'arretes'
end
