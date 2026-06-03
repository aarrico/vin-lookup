class Vin < Data.define(:value)
  FORMAT = /\A[A-HJ-NPR-Z0-9]{17}\z/

  def self.normalize(raw) = raw.to_s.upcase.strip
  def self.valid?(raw) = normalize(raw).match?(FORMAT)
end
