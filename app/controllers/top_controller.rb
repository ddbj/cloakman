class TopController < ApplicationController
  def index
    redirect_to edit_account_path if signed_in?
  end
end
