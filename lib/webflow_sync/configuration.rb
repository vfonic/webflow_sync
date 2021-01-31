# frozen_string_literal: true

module WebflowSync
  class << self
    attr_reader :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(self.configuration)

      self.configuration.api_token ||= ENV.fetch('WEBFLOW_API_TOKEN')
      self.configuration.skip_webflow_sync ||= Rails.env.test?
    end

    private

      attr_writer :configuration
  end

  class Configuration
    attr_accessor :api_token, :skip_webflow_sync, :webflow_site_id

    def api_token=(value)
      @api_token = Webflow.config.api_token = ENV.fetch('WEBFLOW_API_TOKEN')
    end
  end
end
