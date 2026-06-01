VehicleData = Data.define(
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
  :source
) do
  def to_display_hash
    to_h.transform_keys(&:to_s)
        .except("source")
        .merge("powertrain" => powertrain&.to_display_hash)
  end
end
