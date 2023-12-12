# frozen_string_literal: true

module WebflowSync
  class InitialSyncJob < ApplicationJob
    def perform(collection_slug)
      model_class = collection_slug.underscore.classify.constantize
      model_class.where(webflow_item_id: nil).find_each do |record|
        next if record.webflow_site_id.blank?

        collection_id = client(record.webflow_site_id).find_collection_id(collection_slug:)
        client(record.webflow_site_id).create_item(collection_id:, record:)
      end
    end

    private

      def client(site_id)
        if @client&.site_id == site_id
          @client
        else
          @client = WebflowSync::Api.new(site_id:)
        end
      end
  end
end
