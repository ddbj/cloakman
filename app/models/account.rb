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
  validates :password,   presence: true, confirmation: true, on: :create
  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :email,      presence: true

  def self.find(uid)
    res = Keycloak.instance.get("users/#{uid}").parsed

    new(
      id:         res[:id],
      account_id: res[:username],
      first_name: res[:firstName],
      last_name:  res[:lastName],
      email:      res[:email]
    )
  end

  def persisted?
    !!id
  end

  def save
    persisted? ? update : create
  end

  def create(attrs = {})
    assign_attributes attrs

    return false unless valid?(:create)

    res = Keycloak.instance.post("users", **{
      headers: {
        "Content-Type": "application/json"
      },

      body: {
        username:  account_id,
        firstName: first_name,
        lastName:  last_name,
        email:,
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

  def update(attrs = {})
    assign_attributes attrs

    return false unless valid?(:update)

    Keycloak.instance.put("users/#{id}", **{
      headers: {
        "Content-Type": "application/json"
      },

      body: {
        firstName: first_name,
        lastName:  last_name,
        email:     email
      }.to_json
    })

    true
  end
end
