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

  def self.find(uid)
    res   = Keycloak.instance.admin.get("users/#{uid}").parsed
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
      erad_id:              attrs[:eradId]&.first
    )
  end
end
