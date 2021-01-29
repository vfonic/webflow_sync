# frozen_string_literal: true

module WebflowSync
  class DestroyItemJob < ApplicationJob
    def perform(collection_slug:, webflow_site_id:, webflow_item_id:)
      WebflowApi.new(webflow_site_id).delete_item(collection_slug, webflow_item_id)
    end
  end
end
