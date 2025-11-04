if defined?(Aws)
  Aws.use_bundled_cert!
else
  begin
    require "aws-sdk-core"
    Aws.use_bundled_cert!
  rescue LoadError
    # aws-sdk not present; nothing to configure
  end
end
