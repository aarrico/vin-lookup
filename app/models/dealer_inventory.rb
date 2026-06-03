class DealerInventory < ApplicationRecord
  VALID_STATUSES = %w[new_vehicle used certified].freeze

  belongs_to :dealer
  serialize :packages, coder: JSON

  normalizes :vin, with: ->(vin) { Vin.normalize(vin) }
  validates :vin, presence: true, format: { with: Vin::FORMAT }
  validates :status, inclusion: { in: VALID_STATUSES }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
end
