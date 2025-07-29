using LDAPAssertion

class PasswordsController < ApplicationController
  layout 'main'

  class Form
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :current_password, :string
    attribute :new_password,     :string

    validates :current_password,          presence: true
    validates :new_password,              presence: true, length: {minimum: 8, allow_blank: true}, confirmation: true
    validates :new_password_confirmation, presence: true

    def persisted? = true
  end

  def edit
    @form = Form.new
  end

  def update
    @form = Form.new(form_params)

    if @form.valid?
      LDAP.connection.assert_call :password_modify, **{
        dn:           current_user.dn,
        new_password: @form.new_password,
        old_password: @form.current_password
      }

      redirect_to edit_password_path, status: :see_other, notice: 'Password updated successfully.'
    else
      render :edit, status: :unprocessable_content
    end
  rescue LDAPError::UnwillingToPerform
    @form.errors.add :current_password, 'is incorrect'

    render :edit, status: :unprocessable_content
  end

  private

  def form_params
    params.expect(form: [
      :current_password,
      :new_password,
      :new_password_confirmation
    ])
  end
end
