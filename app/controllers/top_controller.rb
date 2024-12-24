class TopController < ApplicationController
  skip_before_action :authenticate!, only: %i[index]
  skip_before_action :require_email_verification!, only: %i[verify_email]

  def index
    redirect_to edit_account_path if signed_in?
  end

  def verify_email
    redirect_to root_path if current_account.email_verified
  end
end
