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

  validates :account_id, presence: true
  validates :password,   presence: true, confirmation: true, on: :create
  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :email,      presence: true

  def self.find(uid)
    res   = Keycloak.instance.get("users/#{uid}").parsed
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
      orcid:                attrs[:arcid]&.first,
      erad_id:              attrs[:eradId]&.first
    )
  end

  def persisted?
    !!id
  end

  def save
    persisted? ? update : create
  end

  def update(attrs = {})
    assign_attributes attrs

    return false unless valid?(:update)

    Keycloak.instance.put("users/#{id}", **{
      headers: {
        "Content-Type": "application/json"
      },

      body: {
        firstName:  first_name,
        lastName:   last_name,
        email:      email,

        attributes: {
          middleName:          [ middle_name ],
          firstNameJapanese:   [ first_name_japanese ],
          lastNameJapanese:    [ last_name_japanese ],
          institution:         [ institution ],
          institutionJapanese: [ institution_japanese ],
          labFacDep:           [ lab_fac_dep ],
          labFacDepJapanese:   [ lab_fac_dep_japanese ],
          url:                 [ url ],
          country:             [ country ],
          postalCode:          [ postal_code ],
          prefecture:          [ prefecture ],
          city:                [ city ],
          street:              [ street ],
          phone:               [ phone ],
          fax:                 [ fax ],
          lang:                [ lang ],
          jobTitle:            [ job_title ],
          jobTitleJapanese:    [ job_title_japanese ],
          orcid:               [ orcid ],
          eradId:              [ erad_id ]
        }
      }.to_json
    })

    true
  rescue OAuth2::Error => e
    parsed = e.response.parsed

    errors.add :base, parsed[:errorMessage] || parsed[:error_description] || parsed[:error] || e.message

    false
  end

  private

  def create(attrs = {})
    assign_attributes attrs

    return false unless valid?(:create)

    res = Keycloak.instance.post("users", **{
      headers: {
        "Content-Type": "application/json"
      },

      body: {
        username:   account_id,
        firstName:  first_name,
        lastName:   last_name,
        email:,
        enabled:    true,

        attributes: {
          middleName: [ middle_name ]
        },

        credentials: [
          type:      "password",
          temporary: false,
          value:     password
        ]
      }.to_json
    })

    self.id = res.response["Location"].split("/").last

    true
  rescue OAuth2::Error => e
    parsed = e.response.parsed

    errors.add :base, parsed[:errorMessage] || parsed[:error_description] || parsed[:error] || e.message

    false
  end
end
