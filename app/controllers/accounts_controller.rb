class AccountsController < ApplicationController
  layout -> {
    action_name.in?(%w[new create]) ? "application" : "main"
  }

  before_action :authenticate!, only: %i[edit update]

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_create_params)

    if @account.save
      session[:uid] = @account.id

      redirect_to edit_account_path, notice: "Account created successfully."
    else
      flash.now[:alert] = @account.errors.full_messages_for(:base).join(", ")

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

  def account_create_params
    params.expect(account: [
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
