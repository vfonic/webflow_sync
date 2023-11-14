# frozen_string_literal: true

module WebflowSync
  class Api
    attr_reader :site_id

    def initialize(site_id = nil)
      @site_id = site_id
    end

    def get_all_items(collection_slug:, page_limit: 100) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      collection_id = find_webflow_collection(collection_slug).fetch(:id)
      max_items_per_page = [page_limit, 100].min
      first_page_number = 1

      result = make_request(:paginate_items, collection_id, page: first_page_number, per_page: max_items_per_page)
      puts "Get all items from WebFlow for #{collection_slug} page: #{first_page_number}"

      total_items = result.dig(:pagination, :total)
      total_pages = (total_items.to_f / max_items_per_page).ceil
      items = result.fetch(:items)

      (2..total_pages).each do |page_number|
        next_page_items = make_request(:paginate_items, collection_id, page: page_number, per_page: max_items_per_page).fetch(:items)
        puts "Get all items from WebFlow for #{collection_slug} page: #{page_number}"

        items.concat next_page_items
      end

      items
    end

    def get_item(collection_slug, webflow_item_id)
      collection = find_webflow_collection(collection_slug)

      make_request(:item, collection.fetch(:id), webflow_item_id)
    end

    def create_item(record, collection_slug)
      collection = find_webflow_collection(collection_slug)
      response = make_request(:create_item, collection.fetch(:id), record.as_webflow_json, publish: true)

      if update_record_columns(record, response)
        puts "Created #{record.inspect} in #{collection_slug}"
        response
      else
        raise "Failed to store webflow_item_id: '#{response.fetch(:id)}' " \
              "after creating item in WebFlow collection #{record.inspect}"
      end
    end

    def update_item(record, collection_slug)
      collection = find_webflow_collection(collection_slug)
      response = make_request(:update_item, collection.fetch(:id), record.webflow_item_id, record.as_webflow_json, publish: true)
      puts "Updated #{record.inspect} in #{collection_slug}"
      response
    end

    def delete_item(collection_slug, webflow_item_id)
      collection = find_webflow_collection(collection_slug)
      response = make_request(:delete_item, collection.fetch(:id), webflow_item_id)
      puts "Deleted #{webflow_item_id} from #{collection_slug}"
      response
    end

    def publish
      response = make_request(:publish, site_id)

      puts "Publish all domains for Webflow site with id: #{site_id}"
      response
    end

    def sites = make_request(:sites)
    def self.sites = new.sites

    private

      def client
        @client ||= ::Webflow::Client.new
      end

      def collections
        @collections ||= make_request(:collections, site_id)
      end

      def find_webflow_collection(collection_slug)
        response = collections.find { |collection| collection.fetch(:slug) == collection_slug }
        raise "Cannot find collection #{collection_slug} for Webflow site #{site_id}" unless response

        response
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
