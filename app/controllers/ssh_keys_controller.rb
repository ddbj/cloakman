class SSHKeysController < ApplicationController
  include SSHKeysControllable

  layout "main"

  def index
    _index current_user
  end

  def new
    _new current_user
  end

  def create
    _create current_user, index_path: ssh_keys_path
  end

  def destroy
    _destroy current_user, index_path: ssh_keys_path
  end
end
