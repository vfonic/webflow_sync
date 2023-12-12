# frozen_string_literal: true

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr'
  config.hook_into :webmock # or :fakeweb
  config.configure_rspec_metadata!
  config.default_cassette_options = { allow_unused_http_interactions: false, record: :none }
  # config.default_cassette_options = { allow_unused_http_interactions: false, record: :new_episodes }
  # use this to filter out sensitive information that you don't want VCR to store in spec/vcr files
  config.filter_sensitive_data('<WEBFLOW_API_TOKEN>') { ENV.fetch('WEBFLOW_API_TOKEN') }
  config.filter_sensitive_data('<WEBFLOW_SITE_ID>') { ENV.fetch('WEBFLOW_SITE_ID') }
end
