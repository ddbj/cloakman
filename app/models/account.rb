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
  attribute :first_name_japanese,   :string
  attribute :last_name_japanese,    :string
  attribute :institution,           :string
  attribute :institution_japanese,  :string
  attribute :lab_fac_dep,           :string
  attribute :lab_fac_dep_japanese,  :string
  attribute :url,                   :string
  attribute :country,               :string
  attribute :postal_code,           :string
  attribute :prefecture,            :string
  attribute :city,                  :string
  attribute :street,                :string
  attribute :phone,                 :string
  attribute :fax,                   :string
  attribute :lang,                  :string
  attribute :job_title,             :string
  attribute :job_title_japanese,    :string
  attribute :orcid,                 :string
  attribute :erad_id,               :string
  attribute :ssh_keys,              default: -> { [] }

  validates :account_id, presence: true
  validates :password,   presence: true, confirmation: true, on: :create
  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :email,      presence: true

  def self.find(uid)
    res   = Keycloak.admin.get("users/#{uid}").parsed
    attrs = res[:attributes] || {}

    new(
      id:                   res[:id],
      account_id:           res[:username],
      email:                res[:email],
      first_name:           res[:firstName],
      middle_name:          attrs[:middleName]&.first,
      last_name:            res[:lastName],
      first_name_japanese:  attrs[:firstNameJapanese]&.first,
      last_name_japanese:   attrs[:lastNameJapanese]&.first,
      institution:          attrs[:institution]&.first,
      institution_japanese: attrs[:institutionJapanese]&.first,
      lab_fac_dep:          attrs[:labFacDep]&.first,
      lab_fac_dep_japanese: attrs[:labFacDepJapanese]&.first,
      url:                  attrs[:url]&.first,
      country:              attrs[:country]&.first,
      postal_code:          attrs[:postalCode]&.first,
      prefecture:           attrs[:prefecture]&.first,
      city:                 attrs[:city]&.first,
      street:               attrs[:street]&.first,
      phone:                attrs[:phone]&.first,
      fax:                  attrs[:fax]&.first,
      lang:                 attrs[:lang]&.first,
      job_title:            attrs[:jobTitle]&.first,
      job_title_japanese:   attrs[:jobTitleJapanese]&.first,
      orcid:                attrs[:orcid]&.first,
      erad_id:              attrs[:eradId]&.first,
      ssh_keys:             attrs[:sshKeys]
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

      body: to_payload(include_username: false).to_json
    })

    true
  rescue OAuth2::Error => e
    parsed = e.response.parsed

    errors.add :base, parsed[:errorMessage] || parsed[:error_description] || parsed[:error] || e.message

    false
  end

  def to_payload(include_id: false, include_username:)
    {
      firstName:  first_name,
      lastName:   last_name,
      email:      email,

      attributes: {
        middleName:          Array(middle_name),
        firstNameJapanese:   Array(first_name_japanese),
        lastNameJapanese:    Array(last_name_japanese),
        institution:         Array(institution),
        institutionJapanese: Array(institution_japanese),
        labFacDep:           Array(lab_fac_dep),
        labFacDepJapanese:   Array(lab_fac_dep_japanese),
        url:                 Array(url),
        country:             Array(country),
        postalCode:          Array(postal_code),
        prefecture:          Array(prefecture),
        city:                Array(city),
        street:              Array(street),
        phone:               Array(phone),
        fax:                 Array(fax),
        lang:                Array(lang),
        jobTitle:            Array(job_title),
        jobTitleJapanese:    Array(job_title_japanese),
        orcid:               Array(orcid),
        eradId:              Array(erad_id),
        sshKeys:             ssh_keys
      }
    }.tap { |payload|
      payload[:id]       = id         if include_id
      payload[:username] = account_id if include_username
    }
  end

  private

  def create
    return false unless valid?(:create)

    res = Keycloak.admin.post("users", **{
      headers: {
        "Content-Type": "application/json"
      },

      body: to_payload(include_username: true).merge(
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
