class AccountsController < ApplicationController
  include ReturnTo

  skip_before_action :authenticate!

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save(context: :sign_up)
      # Back to whoever sent them, when they said where that is.
      #
      # No flash on that branch. It would not be displayed — they are
      # leaving for another host — and would then sit in the session until
      # their next visit here, congratulating them on an account they made
      # last week. Saying "your account is ready, now sign in" is the
      # returning application's job, and it does.
      #
      # `allow_other_host` is the point rather than a loophole: leaving
      # for another host is what a return address is. Rails' guard cannot
      # know which hosts are ours, and ReturnTo already does.
      if (url = return_to)
        redirect_to url, status: :see_other, allow_other_host: true
      else
        redirect_to root_path,
                    status: :see_other,
                    notice: 'Your account has been successfully created. Please sign in to continue.'
      end
    else
      flash.now[:alert] = @user.errors.full_messages_for(:base).join(' ')

      render :new, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: [
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
