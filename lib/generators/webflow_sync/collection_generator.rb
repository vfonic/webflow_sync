# frozen_string_literal: true

require 'rails/generators/active_record'

module WebflowSync
  module Generators
    class CollectionGenerator < Rails::Generators::NamedBase
      desc 'Registers ActiveRecord model to sync to WebFlow collection'

      source_root File.expand_path('templates', __dir__)

      include Rails::Generators::Migration
      def add_migration
        migration_template 'migration.rb.erb', "#{migration_path}/add_webflow_item_id_to_#{table_name}.rb",
                           migration_version: migration_version
      end

      def include_item_sync_in_model_file
        module_snippet = <<~EOS.indent(2)

          include WebflowSync::ItemSync
        EOS

        insert_into_file "app/models/#{name.underscore}.rb", module_snippet, after: / < ApplicationRecord$/
      end

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      private

        def migration_path
          ActiveRecord::Migrator.migrations_paths.first
        end

        def migration_version
          "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
        end
    end
  end
end
