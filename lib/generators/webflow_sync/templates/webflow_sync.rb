WebflowSync.configure do |config|
  # config.skip_webflow_sync = Rails.env.test? # default
  config.webflow_site_id = ENV.fetch('WEBFLOW_SITE_ID')
end
