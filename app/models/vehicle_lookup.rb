class VehicleLookup < ApplicationRecord
  VIN_FORMAT = /\A[A-HJ-NPR-Z0-9]{17}\z/i

  validates :vin, presence: true, uniqueness: true, format: { with: VIN_FORMAT }
  validates :raw_data, presence: true
  validates :decoded_at, presence: true
end
