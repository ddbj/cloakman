class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate!
  before_action :require_email_verification!

  def signed_in?
    session.key?(:uid)
  end

  helper_method :signed_in?

  def authenticate!
    redirect_to root_path, alert: "You must be signed in to access this page." unless signed_in?
  end

  def require_email_verification!
    return unless signed_in?

    redirect_to verify_email_path unless current_account.email_verified
  end

  def current_account
    return nil unless signed_in?

    @current_account ||= Account.find(session[:uid])
  end

  helper_method :current_account
end
