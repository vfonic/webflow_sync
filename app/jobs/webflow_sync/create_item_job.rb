# frozen_string_literal: true

module WebflowSync
  class CreateItemJob < ApplicationJob
    def perform(collection_id:, model_name:, id:)
      return if WebflowSync.configuration.skip_webflow_sync

      model_class = model_name.underscore.classify.constantize
      record = model_class.find_by(id:)
      return if record.blank?
      return if record.skip_webflow_sync
      return if record.webflow_site_id.blank?
      return WebflowSync::UpdateItemJob.perform_later(collection_id:, model_name:, id:) if record.webflow_item_id.present?

      WebflowSync::Api.new(site_id: record.webflow_site_id).create_item(collection_id:, record:)
    end
  end
end
