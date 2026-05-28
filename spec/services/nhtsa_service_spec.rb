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

      it "returns a hash keyed by NHTSA variable name" do
        result = service.decode(gas_vin)
        expect(result).to be_a(Hash)
        expect(result["Make"]).to eq("NISSAN")
        expect(result["Model"]).to eq("Pathfinder")
        expect(result["Model Year"]).to eq("2019")
      end

      it "includes powertrain fields" do
        result = service.decode(gas_vin)
        expect(result["Electrification Level"]).to eq("No applicable")
        expect(result["Displacement (L)"]).to eq("3.5")
        expect(result["Engine Number of Cylinders"]).to eq("6")
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
end
