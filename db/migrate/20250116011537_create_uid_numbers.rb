class CreateUidNumbers < ActiveRecord::Migration[8.0]
  def change
    create_table :uid_numbers do |t|
      t.timestamps
    end
  end
end
