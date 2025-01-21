class TopController < ApplicationController
  allow_unauthenticated_access

  def index
    redirect_to authenticated? ? edit_account_path : new_session_path
  end
end
