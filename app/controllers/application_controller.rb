class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate!

  def authenticate!
    redirect_to root_path, alert: "You must be signed in to access this page." unless signed_in?
  end

  def current_account
    return @current_account if defined?(@current_account)

    if uid = session[:uid]
      begin
        @current_account = Account.find(uid)
      rescue OAuth2::Error
        session.delete :uid

        @current_account = nil
      end
    else
      @current_account = nil
    end
  end

  helper_method :current_account

  def signed_in? = !!current_account

  helper_method :signed_in?
end
