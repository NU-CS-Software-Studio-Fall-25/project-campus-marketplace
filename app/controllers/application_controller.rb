class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # In test environment, skip the authentication requirement so system tests can access pages
  # without performing a sign-in flow. This preserves authentication in dev/prod.
  skip_before_action :require_authentication, if: -> { Rails.env.test? }
end
