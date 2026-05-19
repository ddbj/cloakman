class API::UsersController < API::BaseController
  def index
    filter = Net::LDAP::Filter.eq('inetUserStatus', 'active')

    if query = params[:query].presence
      filter &= %w[uid mail commonName].map {|attr|
        Net::LDAP::Filter.contains(attr, query)
      }.inject(:|)
    end

    render json: serialize(User.search(filter))
  end

  def lookup
    uids = Array.wrap(params[:uids]).compact_blank
    return render(json: []) if uids.empty?

    filter = Net::LDAP::Filter.eq('inetUserStatus', 'active') &
      uids.map {|uid| Net::LDAP::Filter.eq('uid', uid) }.inject(:|)

    render json: serialize(User.search(filter, size: uids.size))
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

  def serialize(users)
    users.sort_by(&:id).map {|user|
      {
        uid:                 user.id,
        full_name:           user.full_name,
        email:               user.email,
        organization:        user.organization,
        account_type_number: user.account_type_number.to_s
      }
    }
  end

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
