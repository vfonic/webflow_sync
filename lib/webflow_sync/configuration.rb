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
    attr_accessor :webflow_site_id
  end
end
