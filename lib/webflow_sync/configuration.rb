# frozen_string_literal: true

module WebflowSync
  class << self
    attr_reader :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    private

      attr_writer :configuration
  end

  class Configuration
    attr_accessor :skip_webflow_sync, :webflow_site_id

    def initialize
      @skip_webflow_sync = Rails.env.test?
    end
  end
end
