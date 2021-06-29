# frozen_string_literal: true

module WebflowSync
  class Api
    attr_reader :site_id

    def initialize(site_id)
      @site_id = site_id
    end

    def get_all_items(collection_slug:, page_limit: 100) # rubocop:disable Metrics/MethodLength
      collection_id = find_webflow_collection(collection_slug)['_id']
      max_items_per_page = page_limit # Webflow::Error: 'limit' must be less than or equal to 100
      first_page_number = 1

      result = make_request(:paginate_items, collection_id, page: first_page_number, per_page: max_items_per_page)
      puts "Get all items from WebFlow for #{collection_slug} page: #{first_page_number}"

      total_items = result['total']
      total_pages = (total_items.to_f / max_items_per_page).ceil
      items = result['items']

      (2..total_pages).each do |page_number|
        next_page_items = make_request(:paginate_items, collection_id,
                                       page: page_number, per_page: max_items_per_page)['items']
        puts "Get all items from WebFlow for #{collection_slug} page: #{page_number}"

        items.concat next_page_items
      end

      items
    end

    def get_item(collection_slug, webflow_item_id)
      collection = find_webflow_collection(collection_slug)

      make_request(:item, collection['_id'], webflow_item_id)
    end

    def create_item(record, collection_slug)
      collection = find_webflow_collection(collection_slug)
      response = make_request(:create_item, collection['_id'],
                              record.as_webflow_json.reverse_merge(_archived: false, _draft: false), live: true)

      if update_record_colums(record, response)
        puts "Created #{record.inspect} in #{collection_slug}"
        response
      else
        raise "Failed to store webflow_item_id: '#{response['_id']}' " \
              "after creating item in WebFlow collection #{record.inspect}"
      end
    end

    def update_item(record, collection_slug)
      collection = find_webflow_collection(collection_slug)
      response = make_request(:update_item, { '_cid' => collection['_id'], '_id' => record.webflow_item_id },
                              record.as_webflow_json.reverse_merge(_archived: false, _draft: false), live: true)

      puts "Updated #{record.inspect} in #{collection_slug}"
      response
    end

    def delete_item(collection_slug, webflow_item_id)
      collection = find_webflow_collection(collection_slug)
      response = make_request(:delete_item, { '_cid' => collection['_id'], '_id' => webflow_item_id })
      # When the item is removed from WebFlow, it's still visible throughout the WebFlow site (probably due to some caching).
      # To remove the item immediately from the WebFlow site, we need to publish the site.
      publish

      puts "Deleted #{webflow_item_id} from #{collection_slug}"
      response
    end

    def publish
      response = make_request(:publish, site_id, domain_names: domain_names)

      puts "Publish all domains for Webflow site with id: #{site_id}"
      response
    end

    private

      def client
        @client ||= ::Webflow::Client.new
      end

      def collections
        @collections ||= client.collections(site_id)
      end

      def domain_names
        @domain_names ||= find_domain_names
      end

      def find_domain_names
        # client.domains request does not return the default domain
        # We need to get default domain name if there are no custom domains set to avoid error:
        # Webflow::Error: Domain not found for site
        site = client.site(site_id)
        default_domain_name = "#{site['shortName']}.webflow.io"
        names = [default_domain_name]
        client.domains(site_id).each { |domain| names << domain['name'] }

        names
      end

      def find_webflow_collection(collection_slug)
        response = collections.find { |collection| collection['slug'] == collection_slug }
        raise "Cannot find collection #{collection_slug} for Webflow site #{site_id}" unless response

        response
      end

      def update_record_colums(record, response)
        # use update_column to skip callbacks to prevent WebflowSync::ItemSync to kick off
        if WebflowSync.configuration.sync_webflow_slug
          record.update_columns(webflow_item_id: response['_id'], webflow_slug: response['slug']) # rubocop:disable Rails/SkipsModelValidations
        else
          record.update_column(:webflow_item_id, response['_id']) # rubocop:disable Rails/SkipsModelValidations
        end
      end

      def make_request(method_name, *args, retries: 0, **kwargs)
        if kwargs.present?
          client.public_send(method_name, *args, **kwargs)
        else
          client.public_send(method_name, *args)
        end
      rescue Webflow::Error => e
        raise if retries >= 8 || e.message.strip != 'Rate limit hit'

        puts "Sleeping #{2**retries} seconds"
        sleep 2**retries
        make_request(method_name, *args, retries: retries + 1, **kwargs)
      end
  end
end
