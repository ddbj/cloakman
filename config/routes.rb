Rails.application.routes.draw do
  root to: "top#index"

  get "auth/:provider/callback", to: "sessions#create", as: :auth_callback
  get "auth/failure",            to: "sessions#failure"

  get "verify_email", to: "top#verify_email"

  resource :session, only: %i[destroy]
  resource :account, only: %i[new edit create update]
  resource :password, only: %i[edit update]
  resources :ssh_keys, only: %i[index new create destroy]

  get "up" => "rails/health#show", as: :rails_health_check
end
