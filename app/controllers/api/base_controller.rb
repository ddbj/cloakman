class API::BaseController < ActionController::Base
  skip_forgery_protection

  before_action :authenticate_with_token!

  private

  def authenticate_with_token!
    authenticate_or_request_with_http_token do |token|
      if key = APIKey.find_by(token:)
        key.tap { it.touch :last_used_at }
      else
        nil
      end
    end
  end
end
