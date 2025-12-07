class ProfanityValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    return unless Obscenity.profane?(value)

    record.errors.add(attribute, options[:message] || "contains inappropriate language")
  end
end
