# frozen_string_literal: true

module WebflowSync
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def add_config_initializer
        template 'webflow_sync.rb', 'config/initializers/webflow_sync.rb'
      end
    end
  end
end
