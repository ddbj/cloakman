class Admin::SSHKeysController < ApplicationController
  include SSHKeysControllable

  layout 'main'

  before_action :authenticate_admin!

  def index
    _index user
  end

  def new
    _new user
  end

  def create
    _create user, index_path: admin_user_ssh_keys_path(user)
  end

  def destroy
    _destroy user, index_path: admin_user_ssh_keys_path(user)
  end

  private

  def user = User.find(params.expect(:user_id))
end
