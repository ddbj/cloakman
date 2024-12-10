Rails.application.routes.draw do
  root to: "top#index"

  resource :account, only: %i[new create]

  get "up" => "rails/health#show", as: :rails_health_check
end
