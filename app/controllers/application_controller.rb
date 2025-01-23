class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate!

  def authenticate!
    redirect_to root_path, alert: "You must be signed in to access this page." unless signed_in?
  end

  def current_account
    return @current_account if defined?(@current_account)

    if username = session[:username]
      begin
        @current_account = Account.find(username)
      rescue ActiveRecord::RecordNotFound
        session.delete :username

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
