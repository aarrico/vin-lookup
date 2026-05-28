require "rails_helper"

RSpec.describe DealerInventory, type: :model do
  let(:dealer) { create(:dealer) }

  describe "validations" do
    it "is valid with required fields" do
      inv = DealerInventory.new(dealer: dealer, vin: "5N1DL0MM1KC557518", status: "new_vehicle")
      expect(inv).to be_valid
    end

    it "is invalid with a malformed VIN" do
      inv = DealerInventory.new(dealer: dealer, vin: "BADVIN", status: "new_vehicle")
      expect(inv).not_to be_valid
      expect(inv.errors[:vin]).to include("is invalid")
    end

    it "is invalid with a VIN containing I, O, or Q" do
      inv = DealerInventory.new(dealer: dealer, vin: "5N1DL0MM1KC55751I", status: "new_vehicle")
      expect(inv).not_to be_valid
    end

    it "is invalid with an unknown status" do
      inv = DealerInventory.new(dealer: dealer, vin: "5N1DL0MM1KC557518", status: "leased")
      expect(inv).not_to be_valid
    end

    it "is invalid with negative price_cents" do
      inv = DealerInventory.new(dealer: dealer, vin: "5N1DL0MM1KC557518",
                                 status: "new_vehicle", price_cents: -1)
      expect(inv).not_to be_valid
    end
  end

  describe "packages" do
    it "stores and retrieves an array" do
      inv = create(:dealer_inventory, packages: [ "Sport Package", "Navigation" ])
      inv.reload
      expect(inv.packages).to eq([ "Sport Package", "Navigation" ])
    end
  end
end
