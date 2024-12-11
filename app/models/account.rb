class Account
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id,                    :string
  attribute :account_id,            :string
  attribute :password,              :string
  attribute :password_confirmation, :string
  attribute :email,                 :string
  attribute :first_name,            :string
  attribute :middle_name,           :string
  attribute :last_name,             :string

  validates :account_id, presence: true
  validates :password,   presence: true, confirmation: true
  validates :email,      presence: true
  validates :first_name, presence: true
  validates :last_name,  presence: true

  def persisted?
    !!id
  end

  def save
    return false unless valid?

    persisted? ? update : create
  end

  def create
    res = Keycloak.instance.post("users", **{
      headers: {
        "Content-Type": "application/json"
      },

      body: {
        username:  account_id,
        email:,
        firstName: first_name,
        lastName:  last_name,
        enabled:   true,

        credentials: [
          type:      "password",
          temporary: false,
          value:     password
        ]
      }.to_json
    })

    self.id = res.response["Location"].split("/").last
  end

  def update
    raise NotImplementedError
  end
end
