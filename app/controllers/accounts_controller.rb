class AccountsController < ApplicationController
  layout -> { action_name.in?(%w[new create]) ? "application" : "main" }

  before_action :authenticate!, only: %i[edit update]

  def new
    @form = CreateAccountForm.new
  end

  def create
    @form = CreateAccountForm.new(create_account_form_params)

    if @form.save
      session[:uid] = @form.account.id

      redirect_to edit_account_path, notice: "Account created successfully."
    else
      flash.now[:alert] = @form.errors.full_messages_for(:base).join(", ")

      render :new, status: :unprocessable_content
    end
  end

  def edit
    @account = current_account
  end

  def update
    @account = current_account

    if @account.update(account_update_params)
      redirect_to edit_account_path, notice: "Account updated successfully."
    else
      flash.now[:alert] = @account.errors.full_messages_for(:base).join(", ")

      render :edit, status: :unprocessable_content
    end
  end

  private

  def create_account_form_params
    params.expect(create_account_form: [
      :account_id,
      :password,
      :password_confirmation,
      :email,
      :first_name,
      :middle_name,
      :last_name
    ])
  end

  def account_update_params
    params.expect(account: [
      :email,
      :first_name,
      :middle_name,
      :last_name
    ])
  end
end
