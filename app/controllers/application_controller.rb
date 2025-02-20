class ApplicationController < ActionController::Base
  include Authentication

  before_action :authenticate!
end
