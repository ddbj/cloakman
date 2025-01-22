class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :username, null: false

      t.timestamps

      t.index :username, unique: true
    end

    create_table :users do |t|
      t.references :account, null: false, foreign_key: true

      t.string  :password_digest, null: false
      t.string  :email,           null: false
      t.string  :first_name,      null: false
      t.string  :first_name_japanese
      t.string  :middle_name
      t.string  :last_name,       null: false
      t.string  :last_name_japanese
      t.string  :job_title
      t.string  :job_title_japanese
      t.string  :orcid
      t.string  :erad_id
      t.string  :organization,    null: false
      t.string  :organization_japanese
      t.string  :lab_fac_dep
      t.string  :lab_fac_dep_japanese
      t.string  :organization_url
      t.string  :country,         null: false
      t.string  :postal_code
      t.string  :prefecture
      t.string  :city,            null: false
      t.string  :street
      t.string  :phone
      t.integer :uid_number,      null: false

      t.timestamps

      t.index :email,      unique: true
      t.index :uid_number, unique: true
    end

    create_table :ssh_keys do |t|
      t.references :user, null: false, foreign_key: true
      t.string     :key,  null: false
      t.string     :title

      t.timestamps
    end
  end
end
