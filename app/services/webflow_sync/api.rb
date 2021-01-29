# frozen_string_literal: true

module WebflowSync
  class Api
    attr_reader :site_id

    def initialize(site_id)
      @site_id = site_id
    end

    def create_item(record, collection_slug)
      collection = find_webflow_collection(collection_slug)
      response = client.create_item(collection['_id'], record.to_webflow_json, live: true)

      record.update!(webflow_item_id: response['_id'])
    end

    def update_item(record, collection_slug)
      collection = find_webflow_collection(collection_slug)
      client.update_item(
        { '_cid' => collection['_id'], '_id' => record.webflow_item_id },
        record.to_webflow_json, live: true
      )
    end

    def delete_item(collection_slug, webflow_item_id)
      collection = find_webflow_collection(collection_slug)
      client.delete_item({ '_cid' => collection['_id'], '_id' => webflow_item_id })
    end

    private

      def client
        @client ||= ::Webflow::Client.new
      end

      def collections
        @collections ||= client.collections(site_id)
      end

      def find_webflow_collection(collection_slug)
        result = collections.find { |collection| collection['slug'] == collection_slug }
        raise "Cannot find collection #{collection_slug} for Webflow site #{site_id}" unless result

        result
      end
  end
end
