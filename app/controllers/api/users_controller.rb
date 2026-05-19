class API::UsersController < API::BaseController
  def index
    filter = Net::LDAP::Filter.eq('inetUserStatus', 'active')
    size   = 100

    if query = params[:query].presence
      filter &= %w[uid mail commonName].map {|attr|
        Net::LDAP::Filter.contains(attr, query)
      }.inject(:|)
    end

    if params.key?(:uids)
      uids = Array(params[:uids]).select(&:present?)

      if uids.empty?
        render json: []
        return
      end

      filter &= uids.map {|uid| Net::LDAP::Filter.eq('uid', uid) }.inject(:|)
      size    = uids.size
    end

    users = User.search(filter, size:).sort_by(&:id).map {|user|
      {
        uid:                 user.id,
        full_name:           user.full_name,
        email:               user.email,
        organization:        user.organization,
        account_type_number: user.account_type_number.to_s
      }
    }

    render json: users
  end

  def create
    user = User.new(user_params)

    if user.save
      head :created
    else
      render json: {errors: user.errors}, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: [
      :id,
      :password,
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
