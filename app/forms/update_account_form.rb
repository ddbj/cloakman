class UpdateAccountForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :account

  attribute :account_id,           :string
  attribute :email,                :string
  attribute :first_name,           :string
  attribute :middle_name,          :string
  attribute :last_name,            :string
  attribute :first_name_japanese,  :string
  attribute :last_name_japanese,   :string
  attribute :institution,          :string
  attribute :institution_japanese, :string
  attribute :lab_fac_dep,          :string
  attribute :lab_fac_dep_japanese, :string
  attribute :url,                  :string
  attribute :country,              :string
  attribute :postal_code,          :string
  attribute :prefecture,           :string
  attribute :city,                 :string
  attribute :street,               :string
  attribute :phone,                :string
  attribute :fax,                  :string
  attribute :lang,                 :string
  attribute :job_title,            :string
  attribute :job_title_japanese,   :string
  attribute :orcid,                :string
  attribute :erad_id,              :string

  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :email,      presence: true

  def self.from(account)
    new(account:, **account.attributes.slice(*attribute_names))
  end

  def update(attrs = {})
    assign_attributes attrs

    return false unless valid?

    account.update attributes.except("account")

    account.errors.full_messages_for(:base).each do |message|
      errors.add :base, message
    end
  end

  def persisted? = true
end
