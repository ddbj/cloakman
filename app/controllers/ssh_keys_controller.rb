class SSHKeysController < ApplicationController
  layout "main"

  def index
  end

  def new
    @form = CreateSSHKeyForm.from(current_account)
  end

  def create
    @form = CreateSSHKeyForm.from(current_account)
    @form.assign_attributes create_ssh_key_form_params

    if @form.save
      redirect_to ssh_keys_path, notice: "SSH key added successfully."
    else
      flash[:alert] = @form.errors.full_messages_for(:base).join(" ")

      render :new, status: :unprocessable_content
    end
  end

  private

  def create_ssh_key_form_params
    params.expect(create_ssh_key_form: [ :ssh_key ])
  end
end
