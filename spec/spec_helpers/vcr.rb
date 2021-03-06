# frozen_string_literal: true

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock # or :fakeweb
  c.configure_rspec_metadata!
  c.default_cassette_options = { record: :none }
  # use this to filter out sensitive information that you don't want VCR to store in spec/vcr files
  c.filter_sensitive_data('<WEBFLOW_API_TOKEN>') { ENV.fetch('WEBFLOW_API_TOKEN') }
  c.filter_sensitive_data('<WEBFLOW_SITE_ID>') { ENV.fetch('WEBFLOW_SITE_ID') }
end
