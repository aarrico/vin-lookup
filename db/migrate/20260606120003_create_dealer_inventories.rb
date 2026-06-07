class CreateDealerInventories < ActiveRecord::Migration[8.1]
  def change
    create_table :dealer_inventories do |t|
      t.references :dealer, null: false, foreign_key: true
      t.string :vin, null: false
      t.integer :price_cents
      t.integer :mileage
      t.string :status
      t.jsonb :custom_fields, null: false, default: {}

      t.timestamps
    end

    add_index :dealer_inventories, :vin
    add_index :dealer_inventories, [ :dealer_id, :vin ], unique: true
  end
end
