# frozen_string_literal: true

# Synchronizes any changes to public records to Webflow
module WebflowSync
  module Callbacks
    extend ActiveSupport::Concern

    included do
      attr_accessor :skip_webflow_sync

      after_commit :create_webflow_item, on: :create
      after_commit :update_webflow_item, on: :update
      after_commit :destroy_webflow_item, on: :destroy

      def create_webflow_item
        return if WebflowSync.configuration.skip_webflow_sync || self.skip_webflow_sync || self.webflow_site_id.blank?

        WebflowSync::CreateItemJob.perform_later(self.model_name.collection, self.id)
      end

      def update_webflow_item
        return if WebflowSync.configuration.skip_webflow_sync || self.skip_webflow_sync || self.webflow_site_id.blank?

        WebflowSync::UpdateItemJob.perform_later(self.model_name.collection, self.id)
      end

      def destroy_webflow_item
        return if WebflowSync.configuration.skip_webflow_sync || self.skip_webflow_sync || self.webflow_site_id.blank?

        # Make sure slug is in the plural form, and multiple words slug separated by dashes
        collection_slug = self.model_name.collection.underscore.dasherize

        WebflowSync::DestroyItemJob.perform_later(collection_slug:,
                                                  webflow_site_id: self.webflow_site_id,
                                                  webflow_item_id: self.webflow_item_id)
      end
    end
  end
end
