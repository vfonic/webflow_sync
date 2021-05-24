# frozen_string_literal: true

module WebflowSync
  class Api
    attr_reader :site_id

    def initialize(site_id)
      @site_id = site_id
    end

    def get_item(collection_slug, webflow_item_id)
      collection = find_webflow_collection(collection_slug)
      client.item(collection['_id'], webflow_item_id)
    end

    def create_item(record, collection_slug) # rubocop:disable Metrics/MethodLength
      collection = find_webflow_collection(collection_slug)
      response = client.create_item(
        collection['_id'],
        record.as_webflow_json.reverse_merge(_archived: false, _draft: false), live: true
      )

      # use update_column to skip callbacks to prevent WebflowSync::ItemSync to kick off
      if record.update_column(:webflow_item_id, response['_id']) # rubocop:disable Rails/SkipsModelValidations
        puts "Created #{record.inspect} in #{collection_slug}"
        response
      else
        raise "Failed to store webflow_item_id: '#{response['_id']}' " \
              "after creating item in WebFlow collection #{record.inspect}"
      end
    end

    def update_item(record, collection_slug)
      collection = find_webflow_collection(collection_slug)
      response = client.update_item(
        { '_cid' => collection['_id'], '_id' => record.webflow_item_id },
        record.as_webflow_json.reverse_merge(_archived: false, _draft: false), live: true
      )
      puts "Updated #{record.inspect} in #{collection_slug}"
      response
    end

    def delete_item(collection_slug, webflow_item_id)
      collection = find_webflow_collection(collection_slug)
      response = client.delete_item({ '_cid' => collection['_id'], '_id' => webflow_item_id })
      puts "Deleted #{webflow_item_id} from #{collection_slug}"
      response
    end

    private

      def client
        @client ||= ::Webflow::Client.new
      end

      def collections
        @collections ||= client.collections(site_id)
      end

      def find_webflow_collection(collection_slug)
        response = collections.find { |collection| collection['slug'] == collection_slug }
        raise "Cannot find collection #{collection_slug} for Webflow site #{site_id}" unless response

        response
      end
  end
end
