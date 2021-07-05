# frozen_string_literal: true

module WebflowSync
  class << self
    attr_reader :configuration

    def configure
      self.configuration ||= Configuration.new

      self.configuration.publish_on_sync = true
      self.configuration.skip_webflow_sync = !Rails.env.production?

      yield(self.configuration)

      self.configuration.api_token ||= ENV.fetch('WEBFLOW_API_TOKEN')
    end

    private

      attr_writer :configuration
  end

  class Configuration
    attr_accessor :skip_webflow_sync, :webflow_site_id, :sync_webflow_slug, :publish_on_sync
    attr_reader :api_token

    def api_token=(value)
      @api_token = Webflow.config.api_token = value
    end
  end
end
