class SessionsController < ApplicationController
  skip_before_action :authenticate!, only: %i[create failure]

  def create
    session[:user_id]  = request.env.dig("omniauth.auth", "extra", "raw_info", "preferred_username")
    session[:id_token] = request.env.dig("omniauth.auth", "credentials", "id_token")

    redirect_to root_path, notice: "You have been logged in."
  end

  def destroy
    keycloak_url = Rails.application.config_for(:keycloak).url!
    logout_url   = URI.join(keycloak_url, "/realms/master/protocol/openid-connect/logout")

    logout_url.query = {
      id_token_hint:            session[:id_token],
      post_logout_redirect_uri: root_url
    }.to_query

    reset_session

    redirect_to logout_url.to_s, notice: "You have been logged out.", allow_other_host: true
  end

  def failure
    redirect_to root_path, alert: params[:message]
  end
end
