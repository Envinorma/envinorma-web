Rails.application.routes.draw do
  root 'installations#index'
  resources :installations
end
