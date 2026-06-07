require "rails_helper"

RSpec.describe InventoryFields do
  describe "STANDARD" do
    it "is the set of typed, queryable inventory columns" do
      expect(described_class::STANDARD).to eq(%w[price_cents status mileage])
    end
  end

  describe "RESERVED" do
    it "includes decode field names and standard field names" do
      expect(described_class::RESERVED).to include(
        "make", "model", "powertrain", "features", "vin",
        "price_cents", "status", "mileage"
      )
    end

    it "excludes the internal decode source field" do
      expect(described_class::RESERVED).not_to include("source")
    end
  end
end
