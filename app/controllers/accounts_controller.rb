class AccountsController < ApplicationController
  layout -> { action_name.in?(%w[new create]) ? "application" : "main" }

  before_action :authenticate!, only: %i[edit update]

  def new
    @form = CreateAccountForm.new
  end

  def create
    @form = CreateAccountForm.new(create_account_form_params)

    if @form.save
      session[:uid] = @form.account.id

      redirect_to edit_account_path, notice: "Account created successfully."
    else
      flash.now[:alert] = @form.errors.full_messages_for(:base).join(", ")

      render :new, status: :unprocessable_content
    end
  end

  def edit
    @form = UpdateAccountForm.from(current_account)
  end

  def update
    @form = UpdateAccountForm.from(current_account)

    if @form.update(update_account_form_params)
      redirect_to edit_account_path, notice: "Account updated successfully."
    else
      flash.now[:alert] = @form.errors.full_messages_for(:base).join(", ")

      render :edit, status: :unprocessable_content
    end
  end

  private

  def create_account_form_params
    params.expect(create_account_form: [
      :account_id,
      :password,
      :password_confirmation,
      :email,
      :first_name,
      :middle_name,
      :last_name
    ])
  end

  def update_account_form_params
    params.expect(update_account_form: [
      :email,
      :first_name,
      :middle_name,
      :last_name,
      :first_name_japanese,
      :last_name_japanese,
      :institution,
      :institution_japanese,
      :lab_fac_dep,
      :lab_fac_dep_japanese,
      :url,
      :country,
      :postal_code,
      :prefecture,
      :city,
      :street,
      :phone,
      :fax,
      :lang,
      :job_title,
      :job_title_japanese,
      :orcid,
      :erad_id
    ])
  end
end
