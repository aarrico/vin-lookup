require "rails_helper"

RSpec.describe PowertrainData do
  subject(:powertrain) do
    described_class.new(
      propulsion: :gas, fuel_primary: "Gasoline", fuel_secondary: nil,
      displacement_l: 3.5, cylinders: 6, electrification_level: "N/A",
      battery_kwh: nil, range_miles: nil, plug_type: nil
    )
  end

  describe "#to_display_hash" do
    it "uses string keys" do
      expect(powertrain.to_display_hash.keys).to all(be_a(String))
    end

    it "stringifies the propulsion enum value" do
      expect(powertrain.to_display_hash["propulsion"]).to eq("gas")
    end

    it "passes non-symbol values through unchanged" do
      result = powertrain.to_display_hash
      expect(result["displacement_l"]).to eq(3.5)
      expect(result["cylinders"]).to eq(6)
      expect(result["battery_kwh"]).to be_nil
    end
  end

  it "is an immutable value object" do
    expect(powertrain).to be_frozen
  end
end
