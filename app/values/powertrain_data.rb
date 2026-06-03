PowertrainData = Data.define(
  :propulsion,
  :fuel_primary,
  :fuel_secondary,
  :displacement_l,
  :cylinders,
  :electrification_level,
  :battery_kwh,
  :range_miles,
  :plug_type
) do
  def to_display_hash
    to_h.transform_values { |v| v.is_a?(Symbol) ? v.to_s : v }
        .transform_keys(&:to_s)
  end
end
