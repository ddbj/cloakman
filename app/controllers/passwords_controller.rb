class PasswordsController < ApplicationController
  class Form
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :user

    attribute :current_password,          :string
    attribute :new_password,              :string
    attribute :new_password_confirmation, :string

    validates :current_password, presence: true
    validates :new_password,     presence: true, confirmation: true

    validates_each :current_password do |record, attr, value|
      unless record.user.authenticate_password(value)
        record.errors.add attr, :invalid
      end
    end

    def persisted? = true

    def save
      return false unless valid?

      user.update(password: new_password)
    end
  end

  layout "main"

  def edit
    @form = Form.new(user: Current.user)
  end

  def update
    @form = Form.new(user: Current.user, **form_params)

    if @form.save
      redirect_to edit_password_path, notice: "Password updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
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
