class Dealer < ApplicationRecord
  has_secure_token :api_key
  has_many :inventory, class_name: "DealerInventory", dependent: :restrict_with_error
  serialize :display_config, coder: JSON

  validates :name, presence: true
end
