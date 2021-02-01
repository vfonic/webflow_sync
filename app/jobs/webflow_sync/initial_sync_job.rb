# frozen_string_literal: true

module WebflowSync
  class InitialSyncJob < ApplicationJob
    def perform(collection_slug)
      model_class = collection_slug.classify.constantize
      model_class.where(webflow_item_id: nil).find_each do |record|
        next if record.webflow_site_id.blank?

        client(record.webflow_site_id).create_item(record, collection_slug)
      end
    end

    private

      def client(site_id)
        if @client&.site_id == site_id
          @client
        else
          @client = WebflowSync::Api.new(site_id)
        end
      end
  end
end
