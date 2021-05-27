# frozen_string_literal: true

Rails.application.routes.draw do
  root 'installations#index'
  get 'installations/search', to: 'installations#search', format: 'json'
  resources :installations do
    resources :classements
    resources :prescriptions
    delete '/prescriptions', to: 'prescriptions#destroy_all', as: 'destroy_all'
  end
  get '/installations/:id/arretes', to: 'arretes#index', as: 'arretes'
  post '/installations/:id/arretes', to: 'arretes#generate_doc_with_prescriptions', as: 'generate_doc'

  get '/user', to: 'users#show'

  get '/pages/:page' => 'pages#show', as: 'page'
end
