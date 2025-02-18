class Admin::UsersController < ApplicationController
  class Form
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :query,               :string
    attribute :inet_user_status,    :string
    attribute :account_type_number, :string

    def build_filter
      filter = Net::LDAP::Filter.eq("objectClass", "ddbjUser")

      if query.present?
        filter = filter & %w[uid mail commonName organizationName].map { |attr|
          Net::LDAP::Filter.contains(attr, query)
        }.inject(:|)
      end

      if inet_user_status.present?
        filter = filter & Net::LDAP::Filter.eq("inetUserStatus", inet_user_status)
      end

      if account_type_number.present?
        value  = User.account_type_number.find_value(account_type_number).value
        filter = filter & Net::LDAP::Filter.eq("accountTypeNumber", value)
      end

      filter
    end
  end

  layout "main"

  before_action :authenticate_admin!

  def index
    @form  = Form.new(form_params)
    @users = User.search(@form.build_filter)
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

  def form_params
    params.fetch(:form, {}).permit(
      :query,
      :inet_user_status,
      :account_type_number
    )
  end

  def user_params
    params.expect(user: [
      :inet_user_status,
      :account_type_number,
      :id,
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
