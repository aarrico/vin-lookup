class DealerInventory < ApplicationRecord
  VIN_FORMAT = /\A[A-HJ-NPR-Z0-9]{17}\z/i
  VALID_STATUSES = %w[new_vehicle used certified].freeze

  belongs_to :dealer
  serialize :packages, coder: JSON

  validates :vin, presence: true, format: { with: VIN_FORMAT }
  validates :status, inclusion: { in: VALID_STATUSES }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
end
