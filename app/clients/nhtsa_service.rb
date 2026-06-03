class NhtsaService
  BASE_URL = "https://vpic.nhtsa.dot.gov/api/vehicles/"

  class Error < StandardError; end
  class NotFoundError < Error; end

  def initialize(client: nil)
    @client = client || Faraday.new(BASE_URL) { |f| f.options.timeout = 5 }
  end

  def decode(vin)
    response = @client.get("DecodeVin/#{vin}", format: "json")
    raise Error, "NHTSA API error: #{response.status}" unless response.success?

    raw = JSON.parse(response.body)
    raise NotFoundError, "VIN not found: #{vin}" if self.class.flatten(raw)["Make"].blank?
    raw
  rescue Faraday::Error => e
    raise Error, e.message
  end

  def self.flatten(raw)
      results = raw.fetch("Results", [])
      results.each_with_object({}) { |r, h| h[r["Variable"]] = r["Value"] }
  end
end
