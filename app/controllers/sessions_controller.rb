class SessionsController < ApplicationController
  skip_before_action :authenticate!, only: %i[create failure]

  def create
    user_info = request.env["omniauth.auth"]

    session[:uid] = user_info["uid"]

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
