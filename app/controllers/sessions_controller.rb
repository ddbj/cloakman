class SessionsController < ApplicationController
  def create
    user_info = request.env["omniauth.auth"]

    session[:uid] = user_info["uid"]

    redirect_to root_path, notice: "You have been logged in."
  end

  def destroy
    session.delete :uid

    redirect_to root_path, notice: "You have been logged out."
  end
end