class CreateDealers < ActiveRecord::Migration[8.1]
  def change
    create_table :dealers do |t|
      t.string :name, null: false
      t.string :api_key, null: false
      t.text :display_config

      t.timestamps
    end

    add_index :dealers, :api_key, unique: true
  end
end
