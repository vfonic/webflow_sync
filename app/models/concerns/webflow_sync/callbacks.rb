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
        return if self.should_skip_webflow_sync?

        WebflowSync::CreateItemJob.perform_later(collection_id: self.webflow_collection_id, model_name: self.model_name.name, id:)
      end

      def update_webflow_item
        return if self.should_skip_webflow_sync?

        WebflowSync::UpdateItemJob.perform_later(collection_id: self.webflow_collection_id, model_name: self.model_name.name, id:)
      end

      def destroy_webflow_item
        return if self.should_skip_webflow_sync?

        WebflowSync::DestroyItemJob.perform_later(collection_id: self.webflow_collection_id, webflow_site_id:, webflow_item_id:)
      end

      private

        def should_skip_webflow_sync?
          WebflowSync.configuration.skip_webflow_sync || self.skip_webflow_sync ||
            self.webflow_site_id.blank? || self.webflow_collection_id.blank?
        end
    end
  end
end
