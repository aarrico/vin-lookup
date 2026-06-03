class DisplayConfig < Data.define(:allowed_fields, :labels)
  def self.from(raw)
    raw ||= {}
    new(allowed_fields: raw["allowed_fields"], labels: raw["labels"] || {})
  end

  def restrict_fields? = !allowed_fields.nil?
  def relabel? = labels.any?
end
