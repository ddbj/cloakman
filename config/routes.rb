Rails.application.routes.draw do
  root to: "top#index"

  get "auth/:provider/callback", to: "sessions#create", as: :auth_callback
  get "auth/failure",            to: "sessions#failure"

  resource :session,   only: %i[destroy]
  resource :account,   only: %i[new create]
  resource :profile,   only: %i[edit update]
  resource :password,  only: %i[edit update]
  resources :ssh_keys, only: %i[index new create destroy]

  namespace :admin do
    resources :users, only: %i[index new create] do
      resource :admin,   only: %i[edit update], controller: "user_admins"
      resource :profile, only: %i[edit update], controller: "user_profiles"
    end

    resources :readers, only: %i[index show new create destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
