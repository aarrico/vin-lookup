require "rails_helper"

RSpec.describe NhtsaAssembler do
  def load_fixture(name)
    json = File.read(Rails.root.join("spec/fixtures/#{name}"))
    results = JSON.parse(json).fetch("Results", [])
    results.each_with_object({}) { |r, h| h[r["Variable"]] = r["Value"] }
  end

  describe ".call" do
    context "with a gas vehicle" do
      let(:hash) { load_fixture("nhtsa_gas_response.json") }
      subject(:vehicle) { described_class.call("5N1DL0MM1KC557518", hash) }

      it "maps basic vehicle fields" do
        expect(vehicle.vin).to eq("5N1DL0MM1KC557518")
        expect(vehicle.year).to eq(2019)
        expect(vehicle.make).to eq("NISSAN")
        expect(vehicle.model).to eq("Pathfinder")
        expect(vehicle.trim).to eq("S")
        expect(vehicle.body_style).to eq("Sport Utility Vehicle (SUV)/Multi-Purpose Vehicle (MPV)")
        expect(vehicle.doors).to eq(4)
        expect(vehicle.drive_type).to eq("FWD/Front-Wheel Drive")
        expect(vehicle.transmission).to eq("Automatic")
      end

      it "sets powertrain type to :gas" do
        expect(vehicle.powertrain.propulsion).to eq(:gas)
      end

      it "maps gas powertrain fields" do
        expect(vehicle.powertrain.fuel_primary).to eq("Gasoline")
        expect(vehicle.powertrain.displacement_l).to eq(3.5)
        expect(vehicle.powertrain.cylinders).to eq(6)
      end

      it "leaves EV fields nil for gas vehicles" do
        expect(vehicle.powertrain.battery_kwh).to be_nil
        expect(vehicle.powertrain.range_miles).to be_nil
        expect(vehicle.powertrain.plug_type).to be_nil
      end

      it "extracts features from the response" do
        expect(vehicle.features).to include(a_string_matching(/Automatic Emergency Braking/))
      end

      it "defaults source to :api" do
        expect(vehicle.source).to eq(:api)
      end

      it "accepts a custom source" do
        v = described_class.call("5N1DL0MM1KC557518", hash, source: :cache)
        expect(v.source).to eq(:cache)
      end
    end

    context "with a BEV" do
      let(:hash) { load_fixture("nhtsa_ev_response.json") }
      subject(:vehicle) { described_class.call("5YJ3E1EA1LF700000", hash) }

      it "sets powertrain type to :ev" do
        expect(vehicle.powertrain.propulsion).to eq(:ev)
      end

      it "maps EV-specific fields" do
        expect(vehicle.powertrain.battery_kwh).to eq(75.0)
        expect(vehicle.powertrain.range_miles).to eq(322)
        expect(vehicle.powertrain.plug_type).to eq("Tesla Connector")
      end

      it "leaves gas fields nil" do
        expect(vehicle.powertrain.displacement_l).to be_nil
        expect(vehicle.powertrain.cylinders).to be_nil
      end
    end

    context "with a PHEV" do
      let(:hash) { load_fixture("nhtsa_phev_response.json") }
      subject(:vehicle) { described_class.call("5UXTE6C50L9B00000", hash) }

      it "sets powertrain type to :plugin_hybrid" do
        expect(vehicle.powertrain.propulsion).to eq(:plugin_hybrid)
      end

      it "maps both gas and EV fields" do
        expect(vehicle.powertrain.displacement_l).to eq(3.0)
        expect(vehicle.powertrain.cylinders).to eq(6)
        expect(vehicle.powertrain.battery_kwh).to eq(24.0)
        expect(vehicle.powertrain.range_miles).to eq(31)
        expect(vehicle.powertrain.plug_type).to eq("SAE J1772")
        expect(vehicle.powertrain.fuel_secondary).to eq("Electric")
      end
    end

    # NHTSA returns the Electrification Level with a parenthetical description
    # (and sometimes a trailing qualifier). The assembler must key off the
    # leading token, not the full string.
    context "with a Strong HEV (full hybrid)" do
      let(:hash) do
        load_fixture("nhtsa_gas_response.json").merge(
          "Electrification Level" => "Strong HEV (Hybrid Electric Vehicle)",
          "Fuel Type - Secondary" => "Electric"
        )
      end
      subject(:vehicle) { described_class.call("STRONGHEV0000000", hash) }

      it "sets powertrain type to :hybrid" do
        expect(vehicle.powertrain.propulsion).to eq(:hybrid)
      end

      it "keeps gas engine fields but has no plug" do
        expect(vehicle.powertrain.displacement_l).to eq(3.5)
        expect(vehicle.powertrain.cylinders).to eq(6)
        expect(vehicle.powertrain.battery_kwh).to be_nil
        expect(vehicle.powertrain.plug_type).to be_nil
      end
    end

    context "with a Mild HEV" do
      let(:hash) do
        load_fixture("nhtsa_gas_response.json").merge(
          "Electrification Level" => "Mild HEV (Hybrid Electric Vehicle)"
        )
      end
      subject(:vehicle) { described_class.call("MILDHEV000000000", hash) }

      it "sets powertrain type to :mild_hybrid" do
        expect(vehicle.powertrain.propulsion).to eq(:mild_hybrid)
      end
    end

    context "with an HEV whose level is unknown" do
      let(:hash) do
        load_fixture("nhtsa_gas_response.json").merge(
          "Electrification Level" => "HEV (Hybrid Electric Vehicle) - Level Unknown"
        )
      end
      subject(:vehicle) { described_class.call("HEVUNKNOWN000000", hash) }

      it "treats it as a full :hybrid despite the trailing qualifier" do
        expect(vehicle.powertrain.propulsion).to eq(:hybrid)
      end
    end

    context "with an FCEV" do
      let(:hash) do
        load_fixture("nhtsa_gas_response.json").merge(
          "Electrification Level" => "FCEV (Fuel Cell Electric Vehicle)",
          "Fuel Type - Primary" => "Fuel Cell"
        )
      end
      subject(:vehicle) { described_class.call("FUELCELL00000000", hash) }

      it "sets powertrain type to :fuel_cell" do
        expect(vehicle.powertrain.propulsion).to eq(:fuel_cell)
      end

      it "has no plug-in fields" do
        expect(vehicle.powertrain.battery_kwh).to be_nil
        expect(vehicle.powertrain.range_miles).to be_nil
        expect(vehicle.powertrain.plug_type).to be_nil
      end
    end
  end
end
