class AccountsController < ApplicationController
  before_action :authenticate!, only: %i[edit update]

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_create_params)

    if @account.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @account = current_account
  end

  def update
    @account = current_account

    if @account.update(account_update_params)
      redirect_to root_path, notice: "Account updated successfully."
    else
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
