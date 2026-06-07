require "rails_helper"

RSpec.describe NhtsaService do
  let(:service) { described_class.new }
  let(:gas_vin) { "5N1DL0MM1KC557518" }
  let(:base_url) { "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin" }

  describe "#decode" do
    context "when NHTSA returns a successful response" do
      before do
        stub_request(:get, "#{base_url}/#{gas_vin}")
          .with(query: { format: "json" })
          .to_return(
            status: 200,
            body: File.read(Rails.root.join("spec/fixtures/nhtsa_gas_response.json")),
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns the full raw NHTSA response (not flattened)" do
        result = service.decode(gas_vin)
        expect(result).to be_a(Hash)
        expect(result["Results"]).to be_an(Array)
      end

      it "preserves raw fields that flattening would discard" do
        result = service.decode(gas_vin)
        expect(result).to have_key("Count")
        make_row = result["Results"].find { |r| r["Variable"] == "Make" }
        expect(make_row["Value"]).to eq("NISSAN")
        expect(make_row["ValueId"]).to eq("476")
      end
    end

    context "when NHTSA returns results with no Make (unknown VIN)" do
      before do
        empty_body = { "Results" => [ { "Variable" => "Make", "Value" => nil } ] }.to_json
        stub_request(:get, "#{base_url}/#{gas_vin}")
          .with(query: { format: "json" })
          .to_return(status: 200, body: empty_body,
                     headers: { "Content-Type" => "application/json" })
      end

      it "raises NhtsaService::NotFoundError" do
        expect { service.decode(gas_vin) }.to raise_error(NhtsaService::NotFoundError)
      end
    end

    context "when NHTSA returns a 500 error" do
      before do
        stub_request(:get, "#{base_url}/#{gas_vin}")
          .with(query: { format: "json" })
          .to_return(status: 500)
      end

      it "raises NhtsaService::Error" do
        expect { service.decode(gas_vin) }.to raise_error(NhtsaService::Error, /500/)
      end
    end

    context "when the request times out" do
      before do
        stub_request(:get, "#{base_url}/#{gas_vin}")
          .with(query: { format: "json" })
          .to_timeout
      end

      it "raises NhtsaService::Error" do
        expect { service.decode(gas_vin) }.to raise_error(NhtsaService::Error)
      end
    end
  end

  describe ".flatten" do
    let(:raw) { JSON.parse(File.read(Rails.root.join("spec/fixtures/nhtsa_gas_response.json"))) }

    it "returns a hash keyed by NHTSA variable name" do
      flat = described_class.flatten(raw)
      expect(flat["Make"]).to eq("NISSAN")
      expect(flat["Model"]).to eq("Pathfinder")
      expect(flat["Model Year"]).to eq("2019")
    end

    it "includes powertrain fields" do
      flat = described_class.flatten(raw)
      expect(flat["Electrification Level"]).to eq("No applicable")
      expect(flat["Displacement (L)"]).to eq("3.5")
      expect(flat["Engine Number of Cylinders"]).to eq("6")
    end
  end
end
