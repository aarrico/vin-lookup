require "rails_helper"

RSpec.describe VehicleData do
  let(:powertrain) do
    PowertrainData.new(
      propulsion: :gas, fuel_primary: "Gasoline", fuel_secondary: nil,
      displacement_l: 3.5, cylinders: 6, electrification_level: "N/A",
      battery_kwh: nil, range_miles: nil, plug_type: nil
    )
  end

  subject(:vehicle_data) do
    described_class.new(
      vin: "5N1DL0MM1KC557518", year: 2019, make: "NISSAN", model: "Pathfinder",
      trim: "S", body_style: "SUV", doors: 4,
      drive_type: "FWD/Front-Wheel Drive", transmission: "Automatic",
      powertrain: powertrain,
      features: [ "Automatic Emergency Braking (AEB): Standard" ],
      source: :api
    )
  end

  describe "#to_display_hash" do
    it "uses string keys" do
      expect(vehicle_data.to_display_hash.keys).to all(be_a(String))
    end

    it "excludes the internal source field" do
      expect(vehicle_data.to_display_hash).not_to have_key("source")
    end

    it "expands the nested powertrain into its display hash" do
      powertrain_hash = vehicle_data.to_display_hash["powertrain"]
      expect(powertrain_hash).to eq(powertrain.to_display_hash)
      expect(powertrain_hash["propulsion"]).to eq("gas")
    end

    it "leaves powertrain nil when absent" do
      without_powertrain = vehicle_data.with(powertrain: nil)
      expect(without_powertrain.to_display_hash["powertrain"]).to be_nil
    end
  end

  it "is an immutable value object" do
    expect(vehicle_data).to be_frozen
  end
end
