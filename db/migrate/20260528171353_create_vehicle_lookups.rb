class CreateVehicleLookups < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicle_lookups do |t|
      t.string :vin, null: false
      t.text :raw_data, null: false
      t.datetime :decoded_at, null: false

      t.timestamps
    end

    add_index :vehicle_lookups, :vin, unique: true
  end
end
