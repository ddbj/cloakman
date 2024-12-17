class PasswordsController < ApplicationController
  layout "main"

  def edit
    @form = UpdatePasswordForm.new(account: current_account)
  end

  def update
    @form = UpdatePasswordForm.new(account: current_account, **update_password_form_params)

    if @form.save
      redirect_to edit_password_path, notice: "Password updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def update_password_form_params
    params.expect(update_password_form: [
      :current_password,
      :new_password,
      :new_password_confirmation
    ])
  end
end
