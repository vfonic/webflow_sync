# frozen_string_literal: true

# Synchronizes any changes to public records to Webflow
module WebflowSync
  module ItemSync
    extend ActiveSupport::Concern

    included do
      attr_accessor :skip_webflow_sync

      after_create :create_webflow_item
      after_update :update_webflow_item
      after_destroy :destroy_webflow_item

      def create_webflow_item
        return if self.skip_webflow_sync || ActiveModel::Type::Boolean.new.cast(ENV['SKIP_WEBFLOW_SYNC'])

        WebflowSync::CreateItemJob.perform_later(self.to_collection_slug, self.id)
      end

      def update_webflow_item
        return if self.skip_webflow_sync || ActiveModel::Type::Boolean.new.cast(ENV['SKIP_WEBFLOW_SYNC'])

        WebflowSync::UpdateItemJob.perform_later(self.to_collection_slug, self.id)
      end

      def destroy_webflow_item
        return if self.skip_webflow_sync || ActiveModel::Type::Boolean.new.cast(ENV['SKIP_WEBFLOW_SYNC'])

        WebflowSync::DestroyItemJob.perform_later(collection_slug: self.to_collection_slug,
                                                  webflow_site_id: self.webflow_site_id,
                                                  webflow_item_id: self.webflow_item_id)
      end
    end
  end
end
