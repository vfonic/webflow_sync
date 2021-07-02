# frozen_string_literal: true

WebflowSync.configure do |config|
  # config.api_token = ENV.fetch('WEBFLOW_API_TOKEN')
  # config.skip_webflow_sync = Rails.env.test? # default
  config.webflow_site_id = ENV.fetch('WEBFLOW_SITE_ID')
  config.sync_webflow_slug = ENV.fetch('SYNC_WEBFLOW_SLUG')
  config.publish_to_all_domains = true
end
