# frozen_string_literal: true

module WebflowSync
  class InitialSyncJob < ApplicationJob
    def perform(collection_slug)
      model_class = collection_slug.classify.constantize
      model_class.where(webflow_item_id: nil).find_each do |record|
        next if record.webflow_site_id.blank?

        WebflowSync::Api.new(record.webflow_site_id).create_item(record, collection_slug)
      end
    end
  end
end
