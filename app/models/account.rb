class Account
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id,                    :string
  attribute :username,              :string
  attribute :password,              :string
  attribute :password_confirmation, :string
  attribute :email,                 :string
  attribute :first_name,            :string
  attribute :middle_name,           :string
  attribute :last_name,             :string
  attribute :first_name_japanese,   :string
  attribute :last_name_japanese,    :string
  attribute :organization,          :string
  attribute :organization_japanese, :string
  attribute :lab_fac_dep,           :string
  attribute :lab_fac_dep_japanese,  :string
  attribute :organization_url,      :string
  attribute :country,               :string
  attribute :postal_code,           :string
  attribute :prefecture,            :string
  attribute :city,                  :string
  attribute :street,                :string
  attribute :phone,                 :string
  attribute :job_title,             :string
  attribute :job_title_japanese,    :string
  attribute :orcid,                 :string
  attribute :erad_id,               :string
  attribute :ssh_keys,              default: -> { [] }

  validates :username,   presence: true
  validates :password,   presence: true, confirmation: true, on: :create
  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :email,      presence: true

  def self.find(uid)
    res   = Keycloak.admin.get("users/#{uid}").parsed
    attrs = res[:attributes] || {}

    new(
      id:                    res[:id],
      username:              res[:username],
      email:                 res[:email],
      first_name:            res[:firstName],
      middle_name:           attrs[:middleName]&.first,
      last_name:             res[:lastName],
      first_name_japanese:   attrs[:firstNameJapanese]&.first,
      last_name_japanese:    attrs[:lastNameJapanese]&.first,
      organization:          attrs[:organization]&.first,
      organization_japanese: attrs[:organizationJapanese]&.first,
      lab_fac_dep:           attrs[:labFacDep]&.first,
      lab_fac_dep_japanese:  attrs[:labFacDepJapanese]&.first,
      organization_url:      attrs[:organizationURL]&.first,
      country:               attrs[:country]&.first,
      postal_code:           attrs[:postalCode]&.first,
      prefecture:            attrs[:prefecture]&.first,
      city:                  attrs[:city]&.first,
      street:                attrs[:street]&.first,
      phone:                 attrs[:phone]&.first,
      job_title:             attrs[:jobTitle]&.first,
      job_title_japanese:    attrs[:jobTitleJapanese]&.first,
      orcid:                 attrs[:orcid]&.first,
      erad_id:               attrs[:eradID]&.first,
      ssh_keys:              attrs[:sshKeys]
    )
  end

  def persisted? = !!id

  def save
    update
  end

  def save!
    unless update
      raise ActiveRecord::RecordInvalid, self
    end
  end

  def update(attrs = {})
    assign_attributes attrs

    return create unless persisted?

    return false unless valid?(:update)

    Keycloak.admin.put("users/#{id}", **{
      headers: {
        "Content-Type": "application/json"
      },

      body: to_payload(id: false, username: false).to_json
    })

    true
  rescue OAuth2::Error => e
    parsed = e.response.parsed

    errors.add :base, parsed[:errorMessage] || parsed[:error_description] || parsed[:error] || e.message

    false
  end

  def to_payload(id:, username:)
    {
      firstName:  first_name,
      lastName:   last_name,
      email:      email,

      attributes: {
        middleName:           Array(middle_name),
        firstNameJapanese:    Array(first_name_japanese),
        lastNameJapanese:     Array(last_name_japanese),
        organization:         Array(organization),
        organizationJapanese: Array(organization_japanese),
        labFacDep:            Array(lab_fac_dep),
        labFacDepJapanese:    Array(lab_fac_dep_japanese),
        organizationURL:      Array(organization_url),
        country:              Array(country),
        postalCode:           Array(postal_code),
        prefecture:           Array(prefecture),
        city:                 Array(city),
        street:               Array(street),
        phone:                Array(phone),
        jobTitle:             Array(job_title),
        jobTitleJapanese:     Array(job_title_japanese),
        orcid:                Array(orcid),
        eradID:               Array(erad_id),
        sshKeys:              ssh_keys
      }
    }.tap { |payload|
      payload[:id]       = self.id       if id
      payload[:username] = self.username if username
    }
  end

  private

  def create
    return false unless valid?(:create)

    res = Keycloak.admin.post("users", **{
      headers: {
        "Content-Type": "application/json"
      },

      body: to_payload(id: false, username: true).merge(
        enabled: true,

        credentials: [
          type:      "password",
          temporary: false,
          value:     password
        ]
      ).to_json
    })

    self.id = res.response["Location"].split("/").last

    true
  rescue OAuth2::Error => e
    parsed = e.response.parsed

    errors.add :base, parsed[:errorMessage] || parsed[:error_description] || parsed[:error] || e.message

    false
  end
end
