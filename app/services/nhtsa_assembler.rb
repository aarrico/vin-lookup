class NhtsaAssembler
  POWERTRAIN_TYPE_MAP = {
    "BEV"        => :ev,
    "FCEV"       => :fuel_cell,
    "PHEV"       => :plugin_hybrid,
    "Mild HEV"   => :mild_hybrid,
    "Strong HEV" => :hybrid,
    "HEV"        => :hybrid # "HEV ... - Level Unknown": treat as a full hybrid
  }.freeze

  FEATURE_VARIABLES = [
    "Automatic Emergency Braking (AEB)",
    "Forward Collision Warning (FCW)",
    "Lane Departure Warning (LDW)",
    "Lane Keeping Assistance (LKA)",
    "Blind Spot Detection (BSD)",
    "Rear Automatic Emergency Braking",
    "Pedestrian Automatic Emergency Braking",
    "Backup Camera",
    "Parking Assist",
    "Adaptive Cruise Control (ACC)"
  ].freeze

  def self.call(vin, nhtsa_hash, source: :api)
    electrification = nhtsa_hash["Electrification Level"].presence
    powertrain_type = powertrain_type_for(electrification)
    has_plug        = %i[ev plugin_hybrid].include?(powertrain_type)
    is_ev           = powertrain_type == :ev

    powertrain = PowertrainData.new(
      type:                  powertrain_type,
      fuel_primary:          nhtsa_hash["Fuel Type - Primary"],
      fuel_secondary:        nhtsa_hash["Fuel Type - Secondary"].presence,
      displacement_l:        is_ev ? nil : nhtsa_hash["Displacement (L)"]&.to_f,
      cylinders:             is_ev ? nil : nhtsa_hash["Engine Number of Cylinders"]&.to_i,
      electrification_level: electrification,
      battery_kwh:           has_plug ? nhtsa_hash["Battery Energy (kWh) From"]&.to_f : nil,
      range_miles:           has_plug ? nhtsa_hash["Range (Electric)"]&.to_i : nil,
      plug_type:             has_plug ? nhtsa_hash["Plug-In Charger Type"].presence : nil
    )

    features = FEATURE_VARIABLES.filter_map do |var|
      val = nhtsa_hash[var].presence
      "#{var}: #{val}" if val && val != "Not Applicable"
    end

    VehicleData.new(
      vin:          vin,
      year:         nhtsa_hash["Model Year"]&.to_i,
      make:         nhtsa_hash["Make"],
      model:        nhtsa_hash["Model"],
      trim:         nhtsa_hash["Trim"].presence,
      body_style:   nhtsa_hash["Body Class"].presence,
      doors:        nhtsa_hash["Doors"]&.to_i,
      drive_type:   nhtsa_hash["Drive Type"].presence,
      transmission: nhtsa_hash["Transmission Style"].presence,
      powertrain:   powertrain,
      features:     features,
      source:       source
    )
  end

  def self.powertrain_type_for(electrification)
    return :gas if electrification.blank?

    match = POWERTRAIN_TYPE_MAP.find { |prefix, _| electrification.start_with?(prefix) }
    match ? match.last : :gas
  end
  private_class_method :powertrain_type_for
end
