module SSHKeysControllable
  class Form
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :user
    attribute :ssh_key, :string

    validates :ssh_key, presence: true

    validate do
      key = SSHData::PublicKey.parse_openssh(ssh_key)

      case key.algo
      when 'ssh-dss'
        errors.add :ssh_key, 'DSA keys are not permitted. Please use RSA, ECDSA, or ED25519 keys instead.'
      when 'ssh-rsa'
        errors.add :ssh_key, 'RSA keys must be at least 2048 bits long.' if key.n.num_bits < 2048
      end
    rescue SSHData::Error
      errors.add :ssh_key, 'Key is invalid. You must supply a key in OpenSSH public key format.'
    end

    def save
      return false unless valid?

      user.ssh_keys << ssh_key.strip
      user.ssh_keys_will_change!

      user.save
    end
  end

  private

  def _index(user)
    @user = user
  end

  def _new(user)
    @form = Form.new(user:)
  end

  def _create(user, index_path:)
    @form = Form.new(user:, **form_params)

    if @form.save
      redirect_to index_path, status: :see_other, notice: 'SSH key added successfully.'
    else
      @form.user.errors[:ssh_keys].each do |error|
        @form.errors.add :ssh_key, error
      end

      render :new, status: :unprocessable_content
    end
  end

  def _destroy(user, index_path:)
    user.ssh_keys.delete_at params.expect(:id).to_i
    user.ssh_keys_will_change!

    user.save!

    redirect_to index_path, status: :see_other, notice: 'SSH key deleted successfully.'
  end

  def form_params
    params.expect(form: [:ssh_key])
  end
end
