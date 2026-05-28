VehicleData = Struct.new(
    :vin,
  :year,
  :make,
  :model,
  :trim,
  :body_style,
  :doors,
  :drive_type,
  :transmission,
  :powertrain,
  :features,
  :source,
  keyword_init: true
)
