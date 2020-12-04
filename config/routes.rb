Rails.application.routes.draw do
  root 'installations#index'
  resources :installations, only: [:index, :show]
  get '/installations/:id/arretes', to: 'arretes#index', as: 'arretes'
  post '/installations/:id/arretes', to: 'arretes#generate_doc_with_prescriptions', as: 'generate_doc'
end
