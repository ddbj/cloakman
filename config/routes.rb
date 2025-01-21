Rails.application.routes.draw do
  root to: "top#index"

  resource :session, only: %i[new create destroy]
  resource :account, only: %i[new edit create update]

  resource :password, only: %i[edit update] do
    resources :resets, only: %i[new create edit update], controller: "password_resets", param: :token
  end

  resources :ssh_keys, only: %i[index new create destroy]

  get "up" => "rails/health#show", as: :rails_health_check
end
