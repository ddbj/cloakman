class AccountsController < ApplicationController
  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)

    if @account.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def account_params
    params.expect(account: [
      :login,
      :password,
      :password_confirmation,
      :email,
      :first_name,
      :middle_name,
      :last_name
    ])
  end
end
