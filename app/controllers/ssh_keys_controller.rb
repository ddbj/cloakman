class SSHKeysController < ApplicationController
  layout "main"

  def index
  end

  def new
    @key = Current.user.ssh_keys.build
  end

  def create
    @key = Current.user.ssh_keys.build(key_params)

    if @key.save
      redirect_to ssh_keys_path, notice: "SSH key added successfully."
    else
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    Current.user.ssh_keys.find(params.expect(:id)).destroy!

    redirect_to ssh_keys_path, notice: "SSH key deleted successfully."
  end

  private

  def key_params
    params.expect(ssh_key: [ :key, :title ])
  end
end
