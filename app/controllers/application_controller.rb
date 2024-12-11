class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def signed_in?
    session.key?(:uid)
  end

  helper_method :signed_in?

  def authenticate!
    redirect_to root_path, alert: "You must be signed in to access this page." unless signed_in?
  end

  def current_account
    return nil unless signed_in?

    @current_account ||= Account.find(session[:uid])
  end

  helper_method :current_account
end
