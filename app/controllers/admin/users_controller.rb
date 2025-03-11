class Admin::UsersController < ApplicationController
  class Form
    include ActiveModel::Model
    include ActiveModel::Attributes

    extend Enumerize

    attribute :query,                :string
    attribute :inet_user_statuses,   default: -> { User.inet_user_status.values }
    attribute :account_type_numbers, default: -> { User.account_type_number.values }
    attribute :sign_in_histories,    default: -> { sign_in_history.values }

    enumerize :sign_in_history, in: %i[has_signed_in never_signed_in]

    def build_filter
      filter = Net::LDAP::Filter.eq("objectClass", "ddbjUser")

      if query.present?
        filter = filter & %w[uid mail commonName].map { |attr|
          Net::LDAP::Filter.contains(attr, query)
        }.inject(:|)
      end

      if statuses = inet_user_statuses.compact_blank.presence
        filter = filter & statuses.map { |status|
          value = User.inet_user_status.find_value(status).value

          Net::LDAP::Filter.eq("inetUserStatus", value)
        }.inject(:|)
      else
        filter = filter & Net::LDAP::Filter.ne("inetUserStatus", "*")
      end

      if types = account_type_numbers.compact_blank.presence
        filter = filter & types.map { |type|
          value = User.account_type_number.find_value(type).value

          Net::LDAP::Filter.eq("accountTypeNumber", value)
        }.inject(:|)
      else
        filter = filter & Net::LDAP::Filter.ne("accountTypeNumber", "*")
      end

      if histories = sign_in_histories.compact_blank.presence
        filter = filter & histories.map { |history|
          case history
          when "has_signed_in"
            Net::LDAP::Filter.present("pwdLastSuccess")
          when "never_signed_in"
            Net::LDAP::Filter.ne("pwdLastSuccess", "*")
          end
        }.inject(:|)
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
    @user = User.new(user_create_params)

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

    if @user.update(user_update_params)
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

      inet_user_statuses:   [],
      account_type_numbers: [],
      sign_in_histories:    []
    )
  end

  def user_create_params
    params.expect(user: [
      :id,
      :password,
      :password_confirmation,
      :email,
      :first_name,
      :first_name_japanese,
      :middle_name,
      :last_name,
      :last_name_japanese,
      :job_title,
      :job_title_japanese,
      :orcid,
      :erad_id,
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
      :inet_user_status,
      :account_type_number,
      :uid_number,
      :gid_number
    ])
  end

  def user_update_params
    params.expect(user: [
      :email,
      :first_name,
      :first_name_japanese,
      :middle_name,
      :last_name,
      :last_name_japanese,
      :job_title,
      :job_title_japanese,
      :orcid,
      :erad_id,
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
      :inet_user_status,
      :account_type_number
    ])
  end
end
