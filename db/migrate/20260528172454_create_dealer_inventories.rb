class CreateDealerInventories < ActiveRecord::Migration[8.1]
  def change
    create_table :dealer_inventories do |t|
      t.references :dealer, null: false, foreign_key: true
      t.string :vin, null: false
      t.string :exterior_color
      t.string :interior_color
      t.integer :price_cents
      t.integer :mileage
      t.string :status
      t.text :packages
      t.text :notes

      t.timestamps
    end

    add_index :dealer_inventories, :vin
    add_index :dealer_inventories, [ :dealer_id, :vin ], unique: true
  end
end
