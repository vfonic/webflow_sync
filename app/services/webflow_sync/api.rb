# frozen_string_literal: true

module WebflowSync
  class Api
    attr_reader :site_id

    def initialize(site_id: nil)
      @site_id = site_id
    end

    def get_all_items(collection_id:) = make_request(:list_all_items, collection_id)

    def get_item(collection_id:, webflow_item_id:) = make_request(:get_item, collection_id, webflow_item_id)

    def create_item(collection_id:, record:)
      response = make_request(:create_item, collection_id, record.as_webflow_json)

      unless update_record_columns(record, response)
        raise "Failed to store webflow_item_id: '#{response.fetch(:id)}' after creating item in WebFlow collection #{record.inspect}"
      end

      response
    end

    def update_item(collection_id:, record:) = make_request(:update_item, collection_id, record.webflow_item_id, record.as_webflow_json)

    def delete_item(collection_id:, webflow_item_id:) = make_request(:delete_item, collection_id, webflow_item_id)

    def publish = make_request(:publish, site_id)

    def sites = make_request(:sites)
    def self.sites = self.new.sites

    def collections
      @collections ||= make_request(:collections, site_id)
    end

    def find_collection_id(collection_slug:)
      response = collections.find { |collection| collection.fetch(:slug) == collection_slug }
      raise "Cannot find collection #{collection_slug} for Webflow site #{site_id}" unless response

      response.fetch(:id)
    end

    private

      def client
        @client ||= Webflow::Client.new
      end

      def update_record_columns(record, response)
        # use update_column to skip callbacks to prevent WebflowSync::ItemSync to kick off
        if WebflowSync.configuration.sync_webflow_slug
          record.update_columns(webflow_item_id: response.fetch(:id), webflow_slug: response.dig(:fieldData, :slug)) # rubocop:disable Rails/SkipsModelValidations
        else
          record.update_column(:webflow_item_id, response.fetch(:id)) # rubocop:disable Rails/SkipsModelValidations
        end
      end

      def make_request(method_name, *args, **kwargs)
        if kwargs.present?
          client.public_send(method_name, *args, **kwargs)
        else
          client.public_send(method_name, *args)
        end
      rescue Webflow::Error => e
        raise unless e.message.strip == 'Too Many Requests'

        puts 'Sleeping 10 seconds'
        sleep 10

        make_request(method_name, *args, **kwargs)
      end
  end
end
