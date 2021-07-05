# frozen_string_literal: true

WebflowSync.configure do |config|
  config.api_token = ENV.fetch('WEBFLOW_API_TOKEN')
  config.webflow_site_id = ENV.fetch('WEBFLOW_SITE_ID')
end
