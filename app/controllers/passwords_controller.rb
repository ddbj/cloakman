class PasswordsController < ApplicationController
  layout "main"

  class Form
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :old_password,              :string
    attribute :new_password,              :string
    attribute :new_password_confirmation, :string

    validates :old_password, presence: true
    validates :new_password, presence: true, confirmation: true

    def persisted? = true
  end

  def edit
    @form = Form.new
  end

  def update
    @form = Form.new(form_params)

    if @form.valid?
      current_account.update_password new_password: @form.new_password, old_password: @form.old_password

      redirect_to edit_password_path, notice: "Password updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  rescue LDAPError::UnwillingToPerform
    @form.errors.add :old_password, "is incorrect"

    render :edit, status: :unprocessable_entity
  end

  private

  def form_params
    params.expect(form: [
      :old_password,
      :new_password,
      :new_password_confirmation
    ])
  end
end
