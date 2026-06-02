require "rails_helper"

RSpec.describe VinLookupService do
  let(:vin) { "5N1DL0MM1KC557518" }
  let(:gas_fixture) { File.read(Rails.root.join("spec/fixtures/nhtsa_gas_response.json")) }
  let(:nhtsa_raw) { JSON.parse(gas_fixture) }

  describe ".call" do
    context "when the VIN is already cached" do
      before { create(:vehicle_lookup, vin: vin, raw_data: gas_fixture) }

      it "returns a VehicleData with source :cache" do
        result = described_class.call(vin)
        expect(result).to be_a(VehicleData)
        expect(result.source).to eq(:cache)
        expect(result.make).to eq("NISSAN")
      end

      it "does not call NhtsaService" do
        expect(NhtsaService).not_to receive(:new)
        described_class.call(vin)
      end
    end

    context "when the VIN is not cached" do
      let(:nhtsa_service) { instance_double(NhtsaService, decode: nhtsa_raw) }

      before do
        allow(NhtsaService).to receive(:new).and_return(nhtsa_service)
      end

      it "calls NhtsaService and returns VehicleData with source :api" do
        result = described_class.call(vin)
        expect(result).to be_a(VehicleData)
        expect(result.source).to eq(:api)
        expect(result.make).to eq("NISSAN")
      end

      it "persists the raw NHTSA response to VehicleLookup" do
        expect { described_class.call(vin) }.to change(VehicleLookup, :count).by(1)
        lookup = VehicleLookup.find_by(vin: vin)
        expect(lookup).to be_present
        expect(lookup.decoded_at).to be_present
        expect(JSON.parse(lookup.raw_data)).to eq(nhtsa_raw)
      end

      it "does not create duplicate cache records on repeat calls" do
        described_class.call(vin)
        described_class.call(vin)
        expect(VehicleLookup.where(vin: vin).count).to eq(1)
      end
    end

    context "when NhtsaService raises an error" do
      before do
        nhtsa_service = instance_double(NhtsaService)
        allow(NhtsaService).to receive(:new).and_return(nhtsa_service)
        allow(nhtsa_service).to receive(:decode).and_raise(NhtsaService::Error, "timeout")
      end

      it "re-raises NhtsaService::Error" do
        expect { described_class.call(vin) }.to raise_error(NhtsaService::Error, "timeout")
      end
    end
  end
end
