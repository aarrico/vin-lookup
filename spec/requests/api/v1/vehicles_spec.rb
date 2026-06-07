require "rails_helper"

RSpec.describe "GET /api/v1/vehicles/:vin", type: :request do
  let(:dealer) { create(:dealer) }
  let(:valid_vin) { "5N1DL0MM1KC557518" }
  let(:headers) { { "X-Dealer-API-Key" => dealer.api_key } }
  let(:gas_fixture) { File.read(Rails.root.join("spec/fixtures/nhtsa_gas_response.json")) }

  before do
    stub_request(:get, %r{vpic\.nhtsa\.dot\.gov/api/vehicles/DecodeVin/#{valid_vin}})
      .to_return(status: 200, body: gas_fixture,
                 headers: { "Content-Type" => "application/json" })
  end

  context "with a valid API key and valid VIN" do
    it "returns 200 with vehicle data" do
      get "/api/v1/vehicles/#{valid_vin}", headers: headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["make"]).to eq("NISSAN")
      expect(body["model"]).to eq("Pathfinder")
      expect(body["year"]).to eq(2019)
    end

    it "includes powertrain data" do
      get "/api/v1/vehicles/#{valid_vin}", headers: headers
      body = JSON.parse(response.body)
      expect(body["powertrain"]).to be_a(Hash)
      expect(body["powertrain"]["propulsion"]).to eq("gas")
    end
  end

  context "with a missing API key" do
    it "returns 401" do
      get "/api/v1/vehicles/#{valid_vin}"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with an invalid API key" do
    it "returns 401" do
      get "/api/v1/vehicles/#{valid_vin}", headers: { "X-Dealer-API-Key" => "bad-key" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with an invalid VIN format" do
    it "returns 422" do
      get "/api/v1/vehicles/BADVIN", headers: headers
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  context "when NHTSA returns an error" do
    before do
      stub_request(:get, %r{vpic\.nhtsa\.dot\.gov/api/vehicles/DecodeVin/#{valid_vin}})
        .to_return(status: 500)
    end

    it "returns 502" do
      get "/api/v1/vehicles/#{valid_vin}", headers: headers
      expect(response).to have_http_status(:bad_gateway)
    end
  end
end
