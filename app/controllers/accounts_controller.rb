class AccountsController < ApplicationController
  layout -> { action_name.in?(%w[new create]) ? "application" : "main" }

  allow_unauthenticated_access only: %i[new create]

  def new
    @account = Account.new
    @account.build_user
  end

  def create
    @account = Account.new(account_create_params)

    saved = ActiveRecord::Base.transaction {
      @account.user.uid_number = User.maximum(:uid_number).to_i + 1

      @account.save
    }

    if saved
      redirect_to new_session_path, notice: "Your user has been successfully created. Please sign in to continue."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @account = Current.user.account
  end

  def update
    @account = Current.user.account

    if @account.update(account_update_params)
      redirect_to edit_account_path, notice: "Profile updated successfully."
    else
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

      user_attributes: [
        :password,
        :password_confirmation,
        *COMMON_ATTRS
      ]
    ])
  end

  def account_update_params
    params.expect(account: [
      user_attributes: [
        :id,
        *COMMON_ATTRS
      ]
    ])
  end
end
