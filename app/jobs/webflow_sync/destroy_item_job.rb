# frozen_string_literal: true

module WebflowSync
  class DestroyItemJob < ApplicationJob
    def perform(collection_id:, webflow_site_id:, webflow_item_id:)
      return if WebflowSync.configuration.skip_webflow_sync
      return if webflow_site_id.blank?
      return if webflow_item_id.blank?

      WebflowSync::Api.new(site_id: webflow_site_id).delete_item(collection_id:, webflow_item_id:)
    end
  end
end
