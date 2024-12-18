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
    account.assign_attributes attributes.except("account")

    return false unless valid?

    Keycloak.admin.put("users/#{account.id}", **{
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

  def persisted? = true
end
