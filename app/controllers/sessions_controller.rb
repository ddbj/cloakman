class SessionsController < ApplicationController
  skip_before_action :authenticate!, only: %i[create failure]

  def create
    session[:username] = request.env.dig("omniauth.auth", "extra", "raw_info", "preferred_username")

    redirect_to root_path, notice: "You have been logged in."
  end

  def destroy
    reset_session

    redirect_to root_path, notice: "You have been logged out."
  end

  def failure
    redirect_to root_path, alert: params[:message]
  end
end
