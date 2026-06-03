class VehicleLookup < ApplicationRecord
  normalizes :vin, with: ->(vin) { Vin.normalize(vin) }

  validates :vin, presence: true, uniqueness: true, format: { with: Vin::FORMAT }
  validates :raw_data, presence: true
  validates :decoded_at, presence: true
end
