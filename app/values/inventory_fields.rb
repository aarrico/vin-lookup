module InventoryFields
  STANDARD = %w[price_cents status mileage].freeze
  DECODE = (VehicleData.members.map(&:to_s) - %w[source]).freeze
  RESERVED = (DECODE + STANDARD).freeze
end
