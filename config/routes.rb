# frozen_string_literal: true

Rails.application.routes.draw do
  root 'installations#index'
  get 'installations/search', to: 'installations#search', format: 'json'
  get 'classement_references/search', to: 'classement_references#search', format: 'json'
  resources :installations do
    resources :classements
    resources :prescriptions, only: %i[index destroy]
    delete '/prescriptions', to: 'prescriptions#destroy_all', as: 'destroy_all'
    post '/prescriptions/from_ap', to: 'prescriptions#create_from_ap', as: 'create_from_ap'
    post '/prescriptions/from_am', to: 'prescriptions#create_or_delete_from_am', as: 'create_or_delete_from_am'
    get '/prescriptions/toggle_grouping', to: 'prescriptions#toggle_grouping', as: 'toggle_grouping'
  end
  get '/installations/new', to: 'installations#new', as: 'new'
  get '/installations/:id/edit_name', to: 'installations#edit_name', as: 'edit_name'
  get '/installations/:id/arretes', to: 'arretes#index', as: 'arretes'
  post '/installations/:id/arretes/fiche_inspection', to: 'arretes#generate_fiche_inspection',
                                                      as: 'generate_fiche_inspection'
  post '/installations/:id/arretes/fiche_gun', to: 'arretes#generate_fiche_gun', as: 'generate_fiche_gun'

  get '/user', to: 'users#show'

  get '/pages/:page' => 'pages#show', as: 'page'
end
