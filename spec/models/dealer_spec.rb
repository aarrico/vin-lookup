require "rails_helper"

RSpec.describe Dealer, type: :model do
  describe "validations" do
    it "is valid with a name" do
      dealer = Dealer.new(name: "Test Motors")
      expect(dealer).to be_valid
    end

    it "is invalid without a name" do
      dealer = Dealer.new(name: nil)
      expect(dealer).not_to be_valid
    end
  end

  describe "api_key" do
    it "generates an api_key on create" do
      dealer = Dealer.create!(name: "Test Motors")
      expect(dealer.api_key).to be_present
    end

    it "generates unique api_keys for different dealers" do
      d1 = Dealer.create!(name: "First Motors")
      d2 = Dealer.create!(name: "Second Motors")
      expect(d1.api_key).not_to eq(d2.api_key)
    end
  end

  describe "display_config" do
    it "returns nil when not set" do
      dealer = Dealer.create!(name: "Test Motors")
      expect(dealer.display_config).to be_nil
    end

    it "stores and retrieves a hash" do
      config = { "allowed_fields" => [ "year", "make", "model" ] }
      dealer = Dealer.create!(name: "Test Motors", display_config: config)
      dealer.reload
      expect(dealer.display_config).to eq(config)
    end
  end
end
