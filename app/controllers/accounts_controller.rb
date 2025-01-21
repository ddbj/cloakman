class AccountsController < ApplicationController
  layout -> { action_name.in?(%w[new create]) ? "application" : "main" }

  allow_unauthenticated_access only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(account_create_params)
    @user.build_uid_number

    if @user.save
      redirect_to new_session_path, notice: "Your user has been successfully created. Please sign in to continue."
    else
      flash.now[:alert] = @user.errors.full_messages_for(:base).join(" ")

      render :new, status: :unprocessable_content
    end
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user

    if @user.update(account_update_params)
      redirect_to edit_account_path, notice: "Profile updated successfully."
    else
      flash.now[:alert] = @user.errors.full_messages_for(:base).join(" ")

      render :edit, status: :unprocessable_content
    end
  end

  private

  COMMON_ATTRS = %i[
    email
    first_name
    middle_name
    last_name
    first_name_japanese
    last_name_japanese
    organization
    organization_japanese
    lab_fac_dep
    lab_fac_dep_japanese
    organization_url
    country
    postal_code
    prefecture
    city
    street
    phone
    job_title
    job_title_japanese
    orcid
    erad_id
  ]

  def account_create_params
    params.expect(account: [
      :username,
      :password,
      :password_confirmation,
      *COMMON_ATTRS
    ])
  end

  def account_update_params
    params.expect(account: COMMON_ATTRS)
  end
end
