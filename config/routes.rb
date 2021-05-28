# frozen_string_literal: true

Rails.application.routes.draw do
  root 'installations#index'
  get 'installations/search', to: 'installations#search', format: 'json'
  resources :installations do
    resources :classements
    resources :prescriptions, only: %i[index destroy]
    delete '/prescriptions', to: 'prescriptions#destroy_all', as: 'destroy_all'
    post '/prescriptions/from_ap', to: 'prescriptions#create_from_ap', as: 'create_from_ap'
    post '/prescriptions/from_am', to: 'prescriptions#create_or_delete_from_am', as: 'create_or_delete_from_am'
  end
  get '/installations/:id/arretes', to: 'arretes#index', as: 'arretes'
  post '/installations/:id/arretes', to: 'arretes#generate_doc_with_prescriptions', as: 'generate_doc'

  get '/user', to: 'users#show'

  get '/pages/:page' => 'pages#show', as: 'page'
end
