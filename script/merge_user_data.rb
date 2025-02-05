require_relative "../config/environment"

require "csv"

using Module.new {
  refine Object do
    def required
      if nil?
        raise "required"
      else
        self
      end
    end
  end
}

csv = CSV.read("tmp/account.other_id.20250207-staging.csv", **{
  headers:           true,
  header_converters: :symbol
}).index_by { it[:account_id] }

ldif = File.read("tmp/userRoot.20250207-staging.ldif")

ldif.split("\n\n").map { |entry|
  entry.lines(chomp: true).map {
    k, v = it.split(': ', 2)

    [ k.to_sym, v ]
  }.group_by(&:first).transform_values { it.map(&:last) }
}.select {
  it[:objectClass].include?('posixAccount')
}.each do |entry|
  next unless entry[:userPassword]

  row = csv.fetch(entry[:uid].first, {})

  puts JSON.generate(
    username:              entry[:uid].first.required,
    password:              entry[:userPassword].first.required,
    email:                 row[:email] || "nobody@nig.ac.jp",
    first_name:            row[:first_name] || "-",
    first_name_japanese:   row[:first_name_japanese],
    middle_name:           row[:middle_name],
    last_name:             row[:last_name] || "-",
    last_name_japanese:    row[:last_name_japanese],
    job_title:             row[:job_title],
    job_title_japanese:    row[:job_title_japanese],
    orcid:                 row[:orcid],
    erad_id:               row[:eradid],
    organization:          row[:institution] || "-",
    organization_japanese: row[:institution_japanese],
    lab_fac_dep:           row[:lab_fac_dep],
    lab_fac_dep_japanese:  row[:lab_fac_dep_japanese],
    organization_url:      row[:url],
    country:               ISO3166::Country.from_alpha3_to_alpha2(row[:country]) || "JP",
    postal_code:           row[:postal_code],
    prefecture:            row[:prefecture],
    city:                  row[:city] || "-",
    street:                row[:street],
    phone:                 row[:phone],
    ssh_keys:              entry[:sshPublicKey] || [],
    account_type_number:   row[:account_type_number] || "1",
    uid_number:            entry[:uidNumber].first.required,
    gid_number:            entry[:gidNumber].first.required,
    home_directory:        entry[:homeDirectory].first.required,
    login_shell:           entry[:loginShell].first.required,
    inet_user_status:      entry[:inetUserStatus].first.required.downcase
  )
end
