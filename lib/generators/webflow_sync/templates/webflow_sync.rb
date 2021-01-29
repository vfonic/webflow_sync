WebflowSync.configure do |config|
  config.webflow_site_id = ENV.fetch('WEBFLOW_SITE_ID')
end
