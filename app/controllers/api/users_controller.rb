class API::UsersController < API::BaseController
  def create
    user = User.new(user_params)

    if user.save
      head :created
    else
      render json: { errors: user.errors }, status: :unprocessable_entity
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
