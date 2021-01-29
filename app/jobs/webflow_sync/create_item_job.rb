# frozen_string_literal: true

module WebflowSync
  class CreateItemJob < ApplicationJob
    def perform(collection_slug, id)
      model_class = collection_slug.classify.constantize
      record = model_class.find_by(id: id)
      return if record.blank?
      return if record.webflow_site_id.blank?

      WebflowSync::Api.new(record.webflow_site_id).create_item(record, collection_slug)
    end
  end
end
