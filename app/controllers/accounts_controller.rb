class AccountsController < ApplicationController
  skip_before_action :authenticate!

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save(context: :create_account)
      redirect_to root_path, notice: "Your account has been successfully created. Please sign in to continue."
    else
      flash.now[:alert] = @user.errors.full_messages_for(:base).join(" ")

      render :new, status: :unprocessable_content
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
