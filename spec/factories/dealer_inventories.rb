FactoryBot.define do
  factory :dealer_inventory do
    association :dealer
    vin { "5N1DL0MM1KC557518" }
    exterior_color { "Lunar Silver Metallic" }
    interior_color { "Black" }
    price_cents { 2_799_900 }
    mileage { 0 }
    status { "new_vehicle" }
    packages { [ "Technology Package", "Premium Package" ] }
    notes { nil }
  end
end
