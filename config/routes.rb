Rails.application.routes.draw do
  root to: "top#index"

  get "auth/:provider/callback", to: "sessions#create", as: :auth_callback

  resource :session, only: %i[destroy]
  resource :account, only: %i[new create edit update]

  get "up" => "rails/health#show", as: :rails_health_check
end
