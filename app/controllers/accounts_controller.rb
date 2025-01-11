class AccountsController < ApplicationController
  layout -> { action_name.in?(%w[new create]) ? "application" : "main" }

  skip_before_action :authenticate!, only: %i[new create]

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_create_params)

    if @account.save
      redirect_to root_path, notice: "Your account has been successfully created. Please sign in to continue."
    else
      flash.now[:alert] = @account.errors.full_messages_for(:base).join(" ")

      render :new, status: :unprocessable_content
    end
  end

  def edit
    @account = current_account
  end

  def update
    @account = current_account

    if @account.update(account_update_params)
      redirect_to edit_account_path, notice: "Profile updated successfully."
    else
      flash.now[:alert] = @account.errors.full_messages_for(:base).join(" ")

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
