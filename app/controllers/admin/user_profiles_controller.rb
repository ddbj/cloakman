class Admin::UserProfilesController < ApplicationController
  layout "main"

  before_action :authenticate_admin!

  def edit
    @user = User.find(params[:user_id])
  end

  def update
    @user = User.find(params[:user_id])

    if @user.update(user_params)
      redirect_to edit_admin_user_profile_path(@user), notice: "User has been successfully updated."
    else
      flash.now[:alert] = @user.errors.full_messages_for(:base).join(" ")

      render :edit, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: [
      :username,
      :password,
      :password_confirmation,
      :email,
      :first_name,
      :middle_name,
      :last_name,
      :first_name_japanese,
      :last_name_japanese,
      :organization,
      :organization_japanese,
      :lab_fac_dep,
      :lab_fac_dep_japanese,
      :organization_url,
      :country,
      :postal_code,
      :prefecture,
      :city,
      :street,
      :phone,
      :job_title,
      :job_title_japanese,
      :orcid,
      :erad_id
    ])
  end
end
