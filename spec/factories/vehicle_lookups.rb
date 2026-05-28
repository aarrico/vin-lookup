FactoryBot.define do
  factory :vehicle_lookup do
    vin { "5N1DL0MM1KC557518" }
    raw_data { File.read(Rails.root.join("spec/fixtures/nhtsa_gas_response.json")) }
    decoded_at { Time.current }
  end
end
