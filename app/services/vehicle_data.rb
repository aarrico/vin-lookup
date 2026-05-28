VehicleData = Struct.new(
    :vin,
    :year,
    :make,
    :model,
    :trim,
    :body_style,
    :fuel_type,
    :displacement,
    :cylinders,
    :drive_type,
    :trasmission,
    :doors,
    :source,
    keyword_init: true
)