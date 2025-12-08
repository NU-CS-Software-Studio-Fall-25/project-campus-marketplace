class ProfanityValidator < ActiveModel::EachValidator
  BLACKLIST = (Obscenity::Base.blacklist || []).map { |w| w.to_s.strip }.reject(&:empty?)

  def validate_each(record, attribute, value)
    return if value.blank?
    return unless profane_whole_word?(value)

    record.errors.add(attribute, options[:message] || "contains inappropriate language")
  end

  private
    def profane_whole_word?(text)
      BLACKLIST.any? do |term|
        pattern = /\b#{Regexp.escape(term)}\b/i
        text.match?(pattern)
      end
    end
end
