class CreateAPIKeys < ActiveRecord::Migration[8.0]
  def change
    create_table :api_keys do |t|
      t.string   :name,  null: false, index: {unique: true}
      t.string   :token, null: false, index: {unique: true}
      t.datetime :last_used_at

      t.timestamps
    end
  end
end
