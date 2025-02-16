require_relative "../config/environment"

using GenerateSSHA

using Module.new {
  refine Object do
    def required
      if blank?
        raise "required"
      else
        self
      end
    end
  end
}

def parse_ldif(path)
  File.read(path).split("\n\n").map { |entry|
    entry.lines(chomp: true).map {
      k, v = it.split(': ', 2)

      [ k.to_sym, v ]
    }.group_by(&:first).transform_values { it.map(&:last) }
  }
end

def parse_tsv(path)
  lines   = IO.readlines(path, chomp: true)
  headers = lines.first.split("\t").map(&:to_sym)

  lines.drop(1).map { |line|
    cols = line.split("\t").map { it.strip.presence }

    headers.zip(cols).to_h
  }
end

def entry_to_json(entry, row)
  uid = entry[:uid].first.required

  {
    username:              uid,
    password_digest:       entry[:userPassword]&.first || random_password.generate_ssha,
    email:                 row[:email].then { it ? it.gsub(/\s/, "").delete_prefix("Example:") : "nobody@ddbj.nig.ac.jp" },
    first_name:            row[:first_name] || "-",
    first_name_japanese:   row[:first_name_japanese],
    middle_name:           row[:middle_name],
    last_name:             row[:last_name] || "-",
    last_name_japanese:    row[:last_name_japanese],
    job_title:             row[:job_title],
    job_title_japanese:    row[:job_title_japanese],
    orcid:                 row[:orcid],
    erad_id:               row[:eradid].then { it&.match?(/\A\d{8}\z/) ? it : nil },
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
    phone:                 row[:phone]&.gsub(/[^\d\-\+]/, ""),
    ssh_keys:              entry[:sshPublicKey] || [],
    account_type_number:   row[:account_type_number].required,
    uid_number:            entry[:uidNumber].first.required,
    gid_number:            entry[:gidNumber]&.first || "61000",
    home_directory:        entry[:homeDirectory]&.first || "/submission/#{uid}",
    login_shell:           entry[:loginShell]&.first || "/bin/bash",
    inet_user_status:      entry[:inetUserStatus].first.required.downcase
  }
end

def random_password
  Base58.binary_to_base58(SecureRandom.random_bytes)
end

entries        = parse_ldif(ARGV[0]).select { it[:uid] }
row_assoc      = parse_tsv(ARGV[1]).index_by { it[:account_id] }
max_uid_number = entries.filter_map { Array(it[:uidNumber]).first&.to_i }.max
emails         = Set.new

entries.each do |entry|
  next unless row   = row_assoc[entry[:uid].first]
  next unless email = row[:email]

  next if emails.include?(email)

  emails << email

  entry[:uidNumber] ||= begin
    max_uid_number += 1

    [ max_uid_number.to_s ]
  end

  puts JSON.generate(entry_to_json(entry, row))
end
