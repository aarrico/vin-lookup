class VehiclePresenter
  def initialize(vehicle_data, dealer, inventory: nil)
    @vehicle_data = vehicle_data
    @dealer = dealer
    @inventory = inventory
    @config = dealer.display_config || {}
  end

  def present
    result = @vehicle_data.to_display_hash
    result = filter_fields(result) if @config["fields"]
    result = apply_labels(result) if @config["labels"]
    result = merge_inventory(result) if @inventory
    result
  end

  private

  def filter_fields(hash)
    allowed = @config["fields"]
    hash.select { |k, _| allowed.include?(k) }
  end

  def apply_labels(hash)
    @config["labels"].each_with_object(hash.dup) do |(original, label), result|
      result[label] = result.delete(original) if result.key?(original)
    end
  end

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
end
