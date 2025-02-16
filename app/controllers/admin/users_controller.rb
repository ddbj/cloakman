class Admin::UsersController < ApplicationController
  layout "main"

  before_action :authenticate_admin!

  def index
    @users = User.search(params[:query])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save(context: :sign_up)
      redirect_to admin_users_path, notice: "User has been successfully creted."
    else
      flash.now[:alert] = @user.errors.full_messages_for(:base).join(" ")

      render :new, status: :unprocessable_content
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User has been successfully updated."
    else
      flash.now[:alert] = @user.errors.full_messages_for(:base).join(" ")

      render :edit, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: [
      :inet_user_status,
      :account_type_number,
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
