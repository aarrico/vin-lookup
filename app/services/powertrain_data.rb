PowertrainData = Struct.new(
  :type,
  :fuel_primary,
  :fuel_secondary,
  :displacement_l,
  :cylinders,
  :electrification_level,
  :battery_kwh,
  :range_miles,
  :plug_type,
  keyword_init: true
)
