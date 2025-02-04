module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :signed_in?
  end

  def authenticate!
    redirect_to root_path, alert: "You must be signed in to access this page." unless signed_in?
  end

  def authenticate_admin!
    head :forbidden unless current_user.account_type_number.ddbj?
  end

  def current_user
    return @current_user if defined?(@current_user)

    if username = session[:username]
      begin
        user = User.find(username)

        if user.inet_user_status == "active"
          @current_user = user
        else
          session.delete :username

          @current_user = nil
        end
      rescue ActiveRecord::RecordNotFound
        session.delete :username

        @current_user = nil
      end
    else
      @current_user = nil
    end
  end

  def signed_in? = !!current_user
end
