module WebflowSync
  class << self
    attr_reader :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    private

      def configuration=(value)
        @configuration = value
      end
  end

  class Configuration
    attr_accessor :skip_webflow_sync
    attr_accessor :webflow_site_id

    def initialize
      @skip_webflow_sync = Rails.env.test?
    end
  end
end
