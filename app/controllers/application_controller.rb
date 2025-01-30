class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate!

  def authenticate!
    redirect_to root_path, alert: "You must be signed in to access this page." unless signed_in?
  end

  def authenticate_admin!
    head :forbidden unless current_user.admin?
  end

  def current_user
    return @current_user if defined?(@current_user)

    if username = session[:username]
      begin
        @current_user = User.find(username)
      rescue ActiveRecord::RecordNotFound
        session.delete :username

        @current_user = nil
      end
    else
      @current_user = nil
    end
  end

  helper_method :current_user

  def signed_in? = !!current_user

  helper_method :signed_in?
end
