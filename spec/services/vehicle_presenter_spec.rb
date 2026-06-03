require "rails_helper"

RSpec.describe VehiclePresenter do
  let(:powertrain) do
    PowertrainData.new(
      propulsion: :gas, fuel_primary: "Gasoline", fuel_secondary: nil,
      displacement_l: 3.5, cylinders: 6, electrification_level: "N/A",
      battery_kwh: nil, range_miles: nil, plug_type: nil
    )
  end

  let(:vehicle_data) do
      VehicleData.new(
        vin: "5N1DL0MM1KC557518", year: 2019, make: "NISSAN", model: "Pathfinder",
        trim: "S", body_style: "Sport Utility Vehicle (SUV)/Multi-Purpose Vehicle (MPV)", doors: 4,
        drive_type: "FWD/Front-Wheel Drive", transmission: "Automatic",
        powertrain: powertrain,
        features: [ "Automatic Emergency Braking (AEB): Standard" ],
        source: :api
      )
    end

  let(:dealer) { create(:dealer, display_config: nil) }

  describe "#present" do
    context "with no display_config (show all fields)" do
      it "returns a hash with string keys" do
        result = described_class.new(vehicle_data, dealer).present
        expect(result).to be_a(Hash)
        expect(result["make"]).to eq("NISSAN")
        expect(result["year"]).to eq(2019)
      end

      it "includes nested powertrain as a hash" do
        result = described_class.new(vehicle_data, dealer).present
        expect(result["powertrain"]).to be_a(Hash)
        expect(result["powertrain"]["propulsion"]).to eq("gas")
        expect(result["powertrain"]["displacement_l"]).to eq(3.5)
      end

      it "does not include source in output" do
        result = described_class.new(vehicle_data, dealer).present
        expect(result.key?("source")).to be false
      end
    end

    context "with a fields allowlist in display_config" do
      before do
        dealer.update!(display_config: { "allowed_fields" => [ "year", "make", "model" ] })
      end

      it "returns only the configured fields" do
        result = described_class.new(vehicle_data, dealer).present
        expect(result.keys).to match_array([ "year", "make", "model" ])
      end

      it "excludes fields not in the allowlist" do
        result = described_class.new(vehicle_data, dealer).present
        expect(result.key?("trim")).to be false
        expect(result.key?("powertrain")).to be false
      end
    end

    context "with label overrides in display_config" do
      before do
        dealer.update!(display_config: {
          "labels" => { "body_style" => "Body Type", "drive_type" => "Drive" }
        })
      end

      it "renames the configured keys" do
        result = described_class.new(vehicle_data, dealer).present
        expect(result.key?("Body Type")).to be true
        expect(result["Body Type"]).to eq("Sport Utility Vehicle (SUV)/Multi-Purpose Vehicle (MPV)")
        expect(result.key?("body_style")).to be false
      end
    end

    context "with a dealer inventory record" do
      let(:inventory) do
        create(:dealer_inventory,
               dealer: dealer,
               vin: vehicle_data.vin,
               exterior_color: "Lunar Silver",
               price_cents: 2_799_900,
               status: "new_vehicle")
      end

      it "merges inventory fields into the response" do
        result = described_class.new(vehicle_data, dealer, inventory: inventory).present
        expect(result["exterior_color"]).to eq("Lunar Silver")
        expect(result["price_cents"]).to eq(2_799_900)
        expect(result["status"]).to eq("new_vehicle")
      end
    end
  end
end
