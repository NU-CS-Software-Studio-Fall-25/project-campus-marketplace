Obscenity.configure do |config|
  # Use the default profanity blacklist and keep replacements consistent if we ever sanitize strings
  config.replacement = :stars
end
