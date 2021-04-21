# frozen_string_literal: true

Rails.application.routes.draw do
  root 'installations#index'
  get 'installations/search', to: 'installations#search', format: 'json'
  get '/installations/:id/duplicate_before_edit', to: 'installations#duplicate_before_edit', as: 'duplicate_before_edit'
  resources :installations do
    resources :classements
  end
  get '/installations/:id/arretes', to: 'arretes#index', as: 'arretes'
  post '/installations/:id/arretes', to: 'arretes#generate_doc_with_prescriptions', as: 'generate_doc'

  resources :prescriptions
  delete '/prescriptions', to: 'prescriptions#remove_prescription', format: :json

  get '/user', to: 'users#show'

  get '/pages/:page' => 'pages#show', as: 'page'
end
