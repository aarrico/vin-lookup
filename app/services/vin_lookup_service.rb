class VinLookupService
  def self.call(vin)
    vin = Vin.normalize(vin)
    cached = VehicleLookup.find_by(vin: vin)

    if cached
      nhtsa_hash = NhtsaService.flatten(JSON.parse(cached.raw_data))
      NhtsaAssembler.call(vin, nhtsa_hash, source: :cache)
    else
      nhtsa_raw = NhtsaService.new.decode(vin)
      nhtsa_hash = NhtsaService.flatten(nhtsa_raw)
      NhtsaAssembler.call(vin, nhtsa_hash, source: :api).tap do
        VehicleLookup.find_or_create_by!(vin: vin) do |record|
          record.raw_data  = nhtsa_raw.to_json
          record.decoded_at = Time.current
        end
      end
    end
  end
end
