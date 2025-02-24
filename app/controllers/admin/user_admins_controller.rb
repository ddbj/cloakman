class Admin::UserAdminsController < ApplicationController
  layout "main"

  before_action :authenticate_admin!

  def edit
    @user = User.find(params[:user_id])
  end

  def update
    @user = User.find(params[:user_id])

    if @user.update(user_params)
      redirect_to edit_admin_user_admin_path(@user), notice: "User has been successfully updated."
    else
      flash.now[:alert] = @user.errors.full_messages_for(:base).join(" ")

      render :edit, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: [
      :account_type_number,
      :inet_user_status
    ])
  end
end
