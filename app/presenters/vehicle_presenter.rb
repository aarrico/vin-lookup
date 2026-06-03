class VehiclePresenter
  def initialize(vehicle_data, dealer, inventory: nil)
    @vehicle_data = vehicle_data
    @dealer = dealer
    @inventory = inventory
    @config = DisplayConfig.from(dealer.display_config)
  end

  def present
    result = to_display_hash(@vehicle_data)
    result = filter_fields(result) if @config.restrict_fields?
    result = apply_display_labels(result) if @config.relabel?
    result = merge_inventory(result) if @inventory
    result
  end

  private

  def filter_fields(hash) = hash.slice(*@config.allowed_fields)

  def apply_display_labels(hash) = hash.transform_keys(@config.labels)

  def merge_inventory(hash)
    inventory_fields = {
      "exterior_color" => @inventory.exterior_color,
      "interior_color" => @inventory.interior_color,
      "price_cents"    => @inventory.price_cents,
      "mileage"        => @inventory.mileage,
      "status"         => @inventory.status,
      "packages"       => @inventory.packages
    }.compact
    hash.merge(inventory_fields)
  end

  def to_display_hash(vehicle_data)
    vehicle_data.to_h
        .transform_keys(&:to_s)
        .except("source")
        .merge("powertrain" => vehicle_data.powertrain&.to_display_hash)
  end
end
