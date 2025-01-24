class TopController < ApplicationController
  skip_before_action :authenticate!

  def index
    redirect_to edit_profile_path if signed_in?
  end
end
