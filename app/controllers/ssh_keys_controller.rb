class SSHKeysController < ApplicationController
  class Form
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :user
    attribute :ssh_key, :string

    validates :ssh_key, presence: true

    validates_each :ssh_key do |record, attr, value|
      SSHData::PublicKey.parse_openssh value
    rescue SSHData::DecodeError
      record.errors.add attr, "Key is invalid. You must supply a key in OpenSSH public key format."
    end

    def save
      return false unless valid?

      user.ssh_keys << ssh_key.strip
      user.ssh_keys_will_change!

      user.save
    end
  end

  layout "main"

  def index
  end

  def new
    @form = Form.new(user: current_user)
  end

  def create
    @form = Form.new(user: current_user, **form_params)

    if @form.save
      redirect_to ssh_keys_path, notice: "SSH key added successfully."
    else
      @form.user.errors[:ssh_keys].each do |error|
        @form.errors.add :ssh_key, error
      end

      render :new, status: :unprocessable_content
    end
  end

  def destroy
    current_user.ssh_keys.delete_at params.expect(:id).to_i
    current_user.ssh_keys_will_change!

    if current_user.save
      redirect_to ssh_keys_path, notice: "SSH key deleted successfully."
    else
      flash[:alert] = current_user.errors.full_messages_for(:base).join(" ")

      render :index, status: :unprocessable_content
    end
  end

  private

  def form_params
    params.expect(form: [ :ssh_key ])
  end
end
