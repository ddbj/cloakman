class HashAPIKeyTokens < ActiveRecord::Migration[8.1]
  def up
    add_column :api_keys, :token_digest, :string

    execute "UPDATE api_keys SET token_digest = encode(sha256(convert_to(token, 'UTF8')), 'hex')"

    change_column_null :api_keys, :token_digest, false
    add_index :api_keys, :token_digest, unique: true
    remove_column :api_keys, :token
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
