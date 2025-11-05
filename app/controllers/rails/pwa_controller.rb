module Rails
  class PwaController < ApplicationController
    skip_forgery_protection
    layout false

    def manifest
      response.headers["Cache-Control"] = "public, max-age=86400, stale-while-revalidate=600"
      render template: "pwa/manifest", formats: :json, content_type: "application/manifest+json"
    end

    def service_worker
      response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
      render template: "pwa/service-worker", formats: :js, content_type: "application/javascript"
    end
  end
end
