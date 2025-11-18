After do
  if defined?(@config_restores) && @config_restores.present?
    @config_restores.each do |key, value|
      Rails.application.config.public_send("#{key}=", value)
    end
    @config_restores = nil
  end
end

Around("@stub_ai_description") do |scenario, block|
  original_method = ImageAnalyzerService.instance_method(:generate_description)

  ImageAnalyzerService.define_method(:generate_description) do
    { description: "Test generated description", category: "electronics" }
  end

  block.call
ensure
  ImageAnalyzerService.define_method(:generate_description, original_method)
end
